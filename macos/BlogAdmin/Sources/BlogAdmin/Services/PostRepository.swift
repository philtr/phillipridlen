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
    let content = post.renderedContent()
    try content.write(to: post.url, atomically: true, encoding: .utf8)
    loadPosts()
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
}
