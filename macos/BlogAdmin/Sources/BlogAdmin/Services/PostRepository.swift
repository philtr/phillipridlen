import Foundation

enum PostScope: String, CaseIterable, Identifiable {
  case notes = "Notes"
  case links = "Links"
  case drafts = "Drafts"

  var id: String { rawValue }
}

final class PostRepository: ObservableObject {
  @Published var posts: [PostFile] = []
  @Published var scope: PostScope = .notes

  private var rootURL: URL? = nil
  private let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "webp"]
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    return formatter
  }()

  func updateRoot(path: String) {
    let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed != "" else {
      rootURL = nil
      posts = []
      return
    }
    rootURL = URL(fileURLWithPath: trimmed)
    loadPosts()
  }

  func loadPosts() {
    guard let rootURL else {
      posts = []
      return
    }

    let target = targetDirectory(for: scope, root: rootURL)
    guard let files = listMarkdownFiles(in: target) else {
      posts = []
      return
    }

    var loaded: [PostFile] = []
    for url in files {
      guard let post = try? PostFile.load(from: url) else { continue }
      if shouldInclude(post: post, in: scope) {
        loaded.append(post)
      }
    }

    posts = loaded.sorted { lhs, rhs in
      if lhs.sortDate != rhs.sortDate {
        return lhs.sortDate > rhs.sortDate
      }
      return lhs.title.lowercased() < rhs.title.lowercased()
    }
  }

  func save(post: PostFile) throws {
    _ = try save(post: post, desiredDate: nil)
  }

  func save(post: PostFile, desiredDate: String?) throws -> PostFile {
    var post = post
    try renamePostIfNeeded(post: &post, desiredDate: desiredDate)
    let content = post.renderedContent()
    try content.write(to: post.url, atomically: true, encoding: .utf8)
    loadPosts()
    return post
  }

  func createPost(
    title: String,
    date: Date,
    category: String,
    tags: [String],
    excerpt: String,
    body: String,
    scope: PostScope
  ) throws -> PostFile {
    guard let rootURL else {
      throw NSError(domain: "BlogAdmin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Repository not set"])
    }

    let target = targetDirectory(for: scope, root: rootURL)
    try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)

    let slug = slugify(title)
    let dateString = dateString(from: date)
    let filenameBase = "\(dateString)-\(slug)"
    let fileURL = uniqueFileURL(in: target, base: filenameBase, ext: "md")

    var data: [String: Any] = [
      "layout": "post",
      "type": scope == .links ? "link" : "note",
      "title": title
    ]

    if category.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
      data["category"] = category
    }
    if !tags.isEmpty {
      data["tags"] = tags
    }
    let frontMatter = FrontMatter(data: data)
    let post = PostFile(id: fileURL.path, url: fileURL, frontMatter: frontMatter, body: body)
    _ = try save(post: post, desiredDate: dateString)
    return post
  }

  func addImages(to post: PostFile, sourceURLs: [URL]) throws -> PostFile {
    var updatedPost = post
    let folder = try ensurePostFolder(for: &updatedPost)

    for source in sourceURLs {
      let ext = source.pathExtension.lowercased()
      guard imageExtensions.contains(ext) else { continue }
      let base = source.deletingPathExtension().lastPathComponent
      let destination = uniqueFileURL(in: folder, base: base, ext: ext)
      try FileManager.default.copyItem(at: source, to: destination)
    }

    loadPosts()
    if let reloaded = posts.first(where: { $0.url == updatedPost.url }) {
      return reloaded
    }
    return updatedPost
  }

  func images(for post: PostFile) -> [URL] {
    guard post.isFolderBased else { return [] }
    let folder = post.folderURL
    guard let enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: nil) else {
      return []
    }
    var results: [URL] = []
    for case let url as URL in enumerator {
      let ext = url.pathExtension.lowercased()
      if imageExtensions.contains(ext) {
        results.append(url)
      }
    }
    return results.sorted { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() }
  }

  private func targetDirectory(for scope: PostScope, root: URL) -> URL {
    switch scope {
    case .notes:
      return root.appendingPathComponent("src/posts/notes")
    case .links:
      return root.appendingPathComponent("src/posts/links")
    case .drafts:
      return root.appendingPathComponent("src/drafts/notes")
    }
  }

  private func listMarkdownFiles(in root: URL) -> [URL]? {
    guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else {
      return nil
    }

    var results: [URL] = []
    for case let url as URL in enumerator {
      if url.pathExtension == "md" {
        results.append(url)
      }
    }
    return results
  }

  private func shouldInclude(post: PostFile, in scope: PostScope) -> Bool {
    let layout = post.frontMatter.string("layout")
    if layout != "post" && layout != "" {
      return false
    }
    let type = post.frontMatter.string("type")
    if scope == .notes && type == "link" { return false }
    if scope == .links && type != "link" { return false }
    return true
  }

  private func ensurePostFolder(for post: inout PostFile) throws -> URL {
    if post.isFolderBased {
      return post.folderURL
    }

    let folderURL = post.folderURL
    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    let destination = folderURL.appendingPathComponent("index.md")

    if FileManager.default.fileExists(atPath: destination.path) {
      return folderURL
    }

    try FileManager.default.moveItem(at: post.url, to: destination)
    post = PostFile(id: destination.path, url: destination, frontMatter: post.frontMatter, body: post.body)
    return folderURL
  }

  private func renamePostIfNeeded(post: inout PostFile, desiredDate: String?) throws {
    let desired = normalizeDateString(desiredDate)
    guard let desired else { return }
    guard let current = post.filenameDateString else { return }
    guard desired != current else { return }

    let slug = extractSlug(from: post)
    let base = "\(desired)-\(slug)"

    if post.isFolderBased {
      let currentFolder = post.folderURL
      let newFolder = currentFolder.deletingLastPathComponent().appendingPathComponent(base)
      if currentFolder != newFolder {
        try FileManager.default.moveItem(at: currentFolder, to: newFolder)
      }
      let newURL = newFolder.appendingPathComponent("index.md")
      post = PostFile(id: newURL.path, url: newURL, frontMatter: post.frontMatter, body: post.body)
    } else {
      let newURL = post.url.deletingLastPathComponent().appendingPathComponent("\(base).md")
      if post.url != newURL {
        try FileManager.default.moveItem(at: post.url, to: newURL)
      }
      post = PostFile(id: newURL.path, url: newURL, frontMatter: post.frontMatter, body: post.body)
    }
  }

  private func extractSlug(from post: PostFile) -> String {
    let name: String
    if post.isFolderBased {
      name = post.folderURL.lastPathComponent
    } else {
      name = post.url.deletingPathExtension().lastPathComponent
    }

    if let range = name.range(of: #"^\d{4}-\d{2}-\d{2}-(.+)$"#, options: .regularExpression) {
      let slug = String(name[range]).replacingOccurrences(of: #"^\d{4}-\d{2}-\d{2}-"#, with: "", options: .regularExpression)
      return slug.isEmpty ? "post" : slug
    }
    return name
  }

  private func normalizeDateString(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    if trimmed.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil {
      return trimmed
    }
    if let date = dateFormatter.date(from: trimmed) {
      return dateString(from: date)
    }
    return nil
  }

  private func dateString(from date: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let year = components.year ?? 0
    let month = components.month ?? 1
    let day = components.day ?? 1
    return String(format: "%04d-%02d-%02d", year, month, day)
  }

  private func uniqueFileURL(in directory: URL, base: String, ext: String) -> URL {
    var candidate = directory.appendingPathComponent("\(base).\(ext)")
    if !FileManager.default.fileExists(atPath: candidate.path) {
      return candidate
    }
    var index = 2
    while true {
      candidate = directory.appendingPathComponent("\(base)-\(index).\(ext)")
      if !FileManager.default.fileExists(atPath: candidate.path) {
        return candidate
      }
      index += 1
    }
  }

  private func slugify(_ input: String) -> String {
    let folded = input.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    var result = ""
    var lastWasDash = false

    for scalar in folded.unicodeScalars {
      if CharacterSet.alphanumerics.contains(scalar) {
        result.append(Character(scalar).lowercased())
        lastWasDash = false
      } else if !lastWasDash {
        result.append("-")
        lastWasDash = true
      }
    }

    let trimmed = result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    return trimmed.isEmpty ? "post" : trimmed
  }
}
