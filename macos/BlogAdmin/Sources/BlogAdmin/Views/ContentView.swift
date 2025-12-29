import AppKit
import Markdown
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @AppStorage("repoPath") private var repoPath: String = ""
  @StateObject private var repository = PostRepository()
  @StateObject private var editor = PostEditorModel()
  @State private var selection: String? = nil
  @State private var showNewPostSheet = false
  @State private var newTitle = ""
  @State private var newDate = Date()
  @State private var newCategory = ""
  @State private var newTags = ""
  @State private var showImageImporter = false
  @State private var postImages: [URL] = []
  @State private var showRenameSlugPrompt = false
  @State private var pendingRenameSlug: String = ""
  @State private var pendingSavePost: PostFile? = nil
  @State private var pendingSaveDate: String = ""
  @State private var originalTitle: String = ""
  @State private var originalSlug: String = ""
  @State private var showDeletePrompt = false
  @State private var pendingDeletePost: PostFile? = nil

  var body: some View {
    NavigationSplitView {
      sidebar
    } detail: {
      detail
    }
    .onAppear {
      repository.updateRoot(path: repoPath)
    }
    .onChange(of: repoPath) { newValue in
      repository.updateRoot(path: newValue)
      selection = nil
      editor.load(post: nil)
    }
    .onChange(of: repository.scope) { _ in
      repository.loadPosts()
      selection = nil
      editor.load(post: nil)
    }
    .onChange(of: selection) { newValue in
      let post = repository.posts.first { $0.id == newValue }
      editor.load(post: post)
      if let post {
        postImages = repository.images(for: post)
        UserDefaults.standard.set(true, forKey: "BlogAdminCanSave")
        originalTitle = post.title
        originalSlug = currentSlug(for: post)
      } else {
        postImages = []
        UserDefaults.standard.set(false, forKey: "BlogAdminCanSave")
        originalTitle = ""
        originalSlug = ""
      }
    }
    .fileImporter(
      isPresented: $showImageImporter,
      allowedContentTypes: imageContentTypes,
      allowsMultipleSelection: true
    ) { result in
      handleImageImport(result)
    }
    .onReceive(NotificationCenter.default.publisher(for: .init("BlogAdminNewPost"))) { _ in
      showNewPostSheet = true
    }
    .onReceive(NotificationCenter.default.publisher(for: .init("BlogAdminSavePost"))) { _ in
      savePost()
    }
    .confirmationDialog(
      "Rename file to match title?",
      isPresented: $showRenameSlugPrompt,
      titleVisibility: .visible
    ) {
      Button("Rename") {
        guard let post = pendingSavePost else { return }
        performSave(post, desiredDate: pendingSaveDate, desiredSlug: pendingRenameSlug)
      }
      Button("Keep Current Name") {
        guard let post = pendingSavePost else { return }
        performSave(post, desiredDate: pendingSaveDate, desiredSlug: nil)
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("The file name doesn’t match the title. Rename the file to match the title?")
    }
    .alert("Delete post?", isPresented: $showDeletePrompt) {
      Button("Delete", role: .destructive) {
        guard let post = pendingDeletePost else { return }
        deletePost(post)
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This will move the post to the Trash.")
    }
    .toolbar {
      ToolbarItemGroup {
        Button {
          showNewPostSheet = true
        } label: {
          Label("New Post", systemImage: "square.and.pencil")
        }
        .labelStyle(.iconOnly)
        .help("New Post")
        .disabled(repoPath.isEmpty)

        Button {
          repository.loadPosts()
        } label: {
          Label("Reload", systemImage: "arrow.clockwise")
        }
        .labelStyle(.iconOnly)
        .help("Reload Posts")

        Button {
          savePost()
        } label: {
          Label("Save", systemImage: "document.circle")
        }
        .labelStyle(.iconOnly)
        .help("Save Post")
        .disabled(editor.post == nil)
      }
    }
    .sheet(isPresented: $showNewPostSheet) {
      newPostSheet
    }
  }

  private var sidebar: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Spacer()
        Picker("", selection: $repository.scope) {
          ForEach(PostScope.allCases) { scope in
            Text(scope.rawValue).tag(scope)
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        Spacer()
      }

      List(selection: $selection) {
        ForEach(groupedPosts, id: \.monthStart) { group in
          Section(group.title) {
            ForEach(group.posts) { post in
              HStack(spacing: 8) {
                Image(systemName: "doc.text")
                  .foregroundStyle(.secondary)
                Text(post.title.isEmpty ? "(Untitled)" : post.title)
              }
              .tag(post.id)
              .contextMenu {
                Button("Edit") {
                  selection = post.id
                }
                Button("Show in Finder") {
                  NSWorkspace.shared.activateFileViewerSelecting([post.url])
                }
                Divider()
                Button("Delete") {
                  pendingDeletePost = post
                  showDeletePrompt = true
                }
              }
            }
          }
        }
      }
      .listStyle(.sidebar)
    }
    .padding(12)
  }

  private var detail: some View {
    ScrollView {
      Group {
        if editor.post == nil {
          emptyState
        } else {
          editorForm
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .padding(16)
    }
  }

  private var emptyState: some View {
    VStack(spacing: 12) {
      Text("Select a post to edit")
        .font(.title2)
      if repoPath.isEmpty {
        Text("Choose your repository to get started.")
          .foregroundStyle(.secondary)
      }
    }
  }

  private var editorForm: some View {
    VStack(spacing: 12) {
      Form {
        TextField("Title", text: $editor.title)
        TextField("Subtitle", text: $editor.subtitle)
        TextField("Description", text: $editor.description)
        DatePicker("Date", selection: dateBinding, displayedComponents: [.date])
        Picker("Category", selection: $editor.category) {
          Text("None").tag("")
          ForEach(categoryOptions, id: \.self) { category in
            Text(category).tag(category)
          }
        }
        .pickerStyle(.menu)
        TextField("Tags", text: $editor.tags)
        Picker("Image", selection: $editor.image) {
          Text("None").tag("")
          ForEach(imageOptions, id: \.self) { image in
            Text(image).tag(image)
          }
        }
        .pickerStyle(.menu)

        LabeledContent("Styles") {
          VStack(alignment: .leading, spacing: 6) {
            ForEach(styleOptions, id: \.self) { style in
              Toggle(style, isOn: Binding(
                get: { editor.styles.contains(style) },
                set: { isOn in
                  if isOn {
                    if !editor.styles.contains(style) {
                      editor.styles.append(style)
                    }
                  } else {
                    editor.styles.removeAll { $0 == style }
                  }
                }
              ))
            }
          }
        }

        if editor.modified.isEmpty {
          Button("Add Modified Date") {
            editor.modified = dateOnlyString(from: Date())
          }
        } else {
          HStack {
            DatePicker("Modified", selection: modifiedBinding, displayedComponents: [.date])
            Button("Clear") { editor.modified = "" }
          }
        }

      }

      TextEditor(text: $editor.body)
        .frame(minHeight: 360)
        .font(.system(size: 15))
        .lineSpacing(4)
        .padding(6)
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(6)

      imagesSection
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, 12)
  }

  private var newPostSheet: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("New Post")
        .font(.title2)

      TextField("Title", text: $newTitle)
      DatePicker("Date", selection: $newDate, displayedComponents: [.date])
      Picker("Category", selection: $newCategory) {
        Text("None").tag("")
        ForEach(categoryOptions, id: \.self) { category in
          Text(category).tag(category)
        }
      }
      .pickerStyle(.menu)
      TextField("Tags (comma separated)", text: $newTags)

      HStack {
        Spacer()
        Button("Cancel") { resetNewPostForm() }
        Button("Create") { createNewPost() }
          .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
    }
    .padding(20)
    .frame(minWidth: 360)
  }

  private var dateBinding: Binding<Date> {
    Binding(
      get: {
        parseDate(editor.date) ?? Date()
      },
      set: { newValue in
        editor.date = dateTimeString(from: newValue, existing: editor.date)
      }
    )
  }

  private var categoryOptions: [String] {
    let values = repository.posts.map { $0.category }.filter { !$0.isEmpty }
    let unique = Array(Set(values)).sorted()
    if editor.category.isEmpty || unique.contains(editor.category) {
      return unique
    }
    return ([editor.category] + unique).filter { !$0.isEmpty }
  }

  private var imageOptions: [String] {
    let filenames = postImages.map { $0.lastPathComponent }
    let unique = Array(Set(filenames)).sorted()
    if editor.image.isEmpty || unique.contains(editor.image) {
      return unique
    }
    return ([editor.image] + unique).filter { !$0.isEmpty }
  }

  private var styleOptions: [String] {
    let values = repository.posts
      .flatMap { $0.frontMatter.stringArray("styles") }
      .filter { !$0.isEmpty }
    let unique = Array(Set(values)).sorted()
    let current = editor.styles.filter { !unique.contains($0) }
    return (current + unique).filter { !$0.isEmpty }
  }

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    return formatter
  }()

  private let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    return formatter
  }()

  private let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    return formatter
  }()

  private func parseDate(_ value: String) -> Date? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    if let parsed = isoFormatter.date(from: trimmed) { return parsed }
    return dateFormatter.date(from: trimmed)
  }

  private func dateOnlyString(from date: Date) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let year = components.year ?? 0
    let month = components.month ?? 1
    let day = components.day ?? 1
    return String(format: "%04d-%02d-%02d", year, month, day)
  }

  private func dateTimeString(from date: Date, existing: String) -> String {
    let timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var components = calendar.dateComponents([.year, .month, .day], from: date)
    components.timeZone = timeZone

    if let existingTime = timeComponents(from: existing) {
      components.hour = existingTime.hour
      components.minute = existingTime.minute
      components.second = existingTime.second
    } else {
      components.hour = 9
      components.minute = 0
      components.second = 0
    }

    let finalDate = calendar.date(from: components) ?? date
    return isoFormatter.string(from: finalDate)
  }

  private func timeComponents(from value: String) -> (hour: Int, minute: Int, second: Int)? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.range(of: #"\d{2}:\d{2}"#, options: .regularExpression) != nil else {
      return nil
    }
    if let parsed = isoFormatter.date(from: trimmed) {
      let calendar = Calendar(identifier: .gregorian)
      let timeZone = TimeZone(identifier: "America/Chicago") ?? .current
      let components = calendar.dateComponents(in: timeZone, from: parsed)
      return (components.hour ?? 9, components.minute ?? 0, components.second ?? 0)
    }
    if let parsed = dateTimeFormatter.date(from: trimmed) {
      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents([.hour, .minute, .second], from: parsed)
      return (components.hour ?? 9, components.minute ?? 0, components.second ?? 0)
    }
    return nil
  }

  private var modifiedBinding: Binding<Date> {
    Binding(
      get: {
        parseDate(editor.modified) ?? Date()
      },
      set: { newValue in
        editor.modified = dateOnlyString(from: newValue)
      }
    )
  }

  private var imagesSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Images")
          .font(.headline)
        Spacer()
        Button("Add Images…") {
          showImageImporter = true
        }
        .disabled(editor.post == nil)
      }

      if postImages.isEmpty {
        Text("No images yet.")
          .foregroundStyle(.secondary)
      } else {
        let columns = [GridItem(.adaptive(minimum: 120), spacing: 12)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
          ForEach(postImages, id: \.self) { url in
            VStack(alignment: .leading, spacing: 6) {
              if let image = NSImage(contentsOf: url) {
                Image(nsImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 120, height: 90)
                  .clipped()
                  .cornerRadius(6)
              } else {
                RoundedRectangle(cornerRadius: 6)
                  .fill(Color.gray.opacity(0.2))
                  .frame(width: 120, height: 90)
              }

              Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)

              HStack(spacing: 8) {
                Button("Copy Markdown") { copyMarkdown(for: url) }
                  .buttonStyle(.bordered)
                Button("Reveal") { NSWorkspace.shared.activateFileViewerSelecting([url]) }
                  .buttonStyle(.bordered)
              }
            }
          }
        }
      }
    }
    .padding(.top, 8)
  }

  private var imageContentTypes: [UTType] {
    var types: [UTType] = [.jpeg, .png, .gif]
    if let webp = UTType("org.webmproject.webp") {
      types.append(webp)
    }
    return types
  }

  private func handleImageImport(_ result: Result<[URL], Error>) {
    guard let post = editor.post else { return }
    switch result {
    case let .success(urls):
      do {
        let updated = try repository.addImages(to: post, sourceURLs: urls)
        editor.load(post: updated)
        postImages = repository.images(for: updated)
        selection = updated.id
      } catch {
        NSSound.beep()
      }
    case .failure:
      break
    }
  }

  private func copyMarkdown(for url: URL) {
    let filename = url.lastPathComponent
    let alt = url.deletingPathExtension().lastPathComponent
    let snippet = "![\(alt)](\(filename))"
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(snippet, forType: .string)
  }

  private func createNewPost() {
    let tags = newTags
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }

    do {
      let post = try repository.createPost(
        title: newTitle,
        date: newDate,
        category: newCategory,
        tags: tags,
        excerpt: "",
        body: "",
        scope: repository.scope
      )
      selection = post.id
      editor.load(post: post)
      resetNewPostForm()
    } catch {
      NSSound.beep()
    }
  }

  private func resetNewPostForm() {
    showNewPostSheet = false
    newTitle = ""
    newDate = Date()
    newCategory = ""
    newTags = ""
  }

  

  

  private struct PostGroup {
    let monthStart: Date
    let title: String
    let posts: [PostFile]
  }

  private var groupedPosts: [PostGroup] {
    let calendar = Calendar.current
    let groups = Dictionary(grouping: repository.posts) { post in
      let date = post.sortDate
      return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? Date.distantPast
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    formatter.locale = Locale.current

    return groups.keys.sorted(by: >).map { key in
      let posts = groups[key, default: []].sorted { $0.sortDate > $1.sortDate }
      return PostGroup(monthStart: key, title: formatter.string(from: key), posts: posts)
    }
  }


  private func savePost() {
    guard let updated = editor.updatedPost() else { return }
    let desiredSlug = slugify(editor.title)
    let titleChanged = editor.title != originalTitle
    if titleChanged && desiredSlug != "" && desiredSlug != currentSlug(for: updated) {
      pendingSavePost = updated
      pendingRenameSlug = desiredSlug
      pendingSaveDate = editor.date
      showRenameSlugPrompt = true
      return
    }

    performSave(updated, desiredDate: editor.date, desiredSlug: nil)
  }

  private func performSave(_ post: PostFile, desiredDate: String, desiredSlug: String?) {
    do {
      var wrapped = post
      wrapped.body = hardWrapMarkdown(post.body, width: 80)
      editor.body = wrapped.body
      _ = Document(parsing: post.body)
      let saved = try repository.save(post: wrapped, desiredDate: desiredDate, desiredSlug: desiredSlug)
      selection = saved.id
      editor.load(post: saved)
      postImages = repository.images(for: saved)
      originalTitle = saved.title
      originalSlug = currentSlug(for: saved)
    } catch {
      NSSound.beep()
    }
  }

  private func currentSlug(for post: PostFile) -> String {
    if post.isFolderBased {
      return post.folderURL.lastPathComponent
    }
    return post.url.deletingPathExtension().lastPathComponent
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

  private func deletePost(_ post: PostFile) {
    do {
      let url = post.isFolderBased ? post.folderURL : post.url
      try FileManager.default.trashItem(at: url, resultingItemURL: nil)
      repository.loadPosts()
      if selection == post.id {
        selection = nil
        editor.load(post: nil)
        postImages = []
        UserDefaults.standard.set(false, forKey: "BlogAdminCanSave")
      }
    } catch {
      NSSound.beep()
    }
  }

  private func hardWrapMarkdown(_ text: String, width: Int) -> String {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    var output: [String] = []
    var paragraph: [String] = []
    var inCodeFence = false

    func flushParagraph() {
      guard !paragraph.isEmpty else { return }
      let firstLine = paragraph[0]
      let trimmedFirst = firstLine.trimmingCharacters(in: .whitespaces)

      if trimmedFirst.hasPrefix("#") && paragraph.count == 1 {
        output.append(firstLine)
        paragraph.removeAll()
        return
      }

      let blockquotePrefix = matchPrefix(in: firstLine, pattern: #"^(\s*>+\s+)"#)
      let listPrefix = matchPrefix(in: firstLine, pattern: #"^(\s*(?:[-*+]|\d+\.)\s+)"#)

      let prefix: String
      let continuationPrefix: String
      if let blockquotePrefix {
        prefix = blockquotePrefix
        continuationPrefix = blockquotePrefix
      } else if let listPrefix {
        prefix = listPrefix
        continuationPrefix = String(repeating: " ", count: listPrefix.count)
      } else {
        prefix = ""
        continuationPrefix = ""
      }

      let content = paragraph
        .map { line in
          if prefix != "", line.hasPrefix(prefix) {
            return String(line.dropFirst(prefix.count))
          }
          return line.trimmingCharacters(in: .whitespaces)
        }
        .joined(separator: " ")
        .trimmingCharacters(in: .whitespaces)

      let contentWidth = max(1, width - prefix.count)
      let wrappedLines = wrapText(content, width: contentWidth)

      for (index, line) in wrappedLines.enumerated() {
        if index == 0 {
          output.append(prefix + line)
        } else {
          output.append(continuationPrefix + line)
        }
      }

      paragraph.removeAll()
    }

    for rawLine in lines {
      let line = String(rawLine)
      let trimmed = line.trimmingCharacters(in: .whitespaces)

      if trimmed.hasPrefix("```") {
        flushParagraph()
        output.append(line)
        inCodeFence.toggle()
        continue
      }

      if inCodeFence {
        output.append(line)
        continue
      }

      if trimmed.range(of: #"^\s*\[[^\]]+\]:\s+\S+"#, options: .regularExpression) != nil {
        flushParagraph()
        output.append(line)
        continue
      }

      if trimmed.isEmpty {
        flushParagraph()
        output.append(line)
        continue
      }

      if line.hasPrefix("    ") || line.hasPrefix("\t") {
        flushParagraph()
        output.append(line)
        continue
      }

      paragraph.append(line)
    }

    flushParagraph()
    return output.joined(separator: "\n")
  }

  private func wrapText(_ text: String, width: Int) -> [String] {
    let words = text.split(whereSeparator: { $0.isWhitespace })
    guard !words.isEmpty else { return [""] }

    var lines: [String] = []
    var current = ""

    for wordSub in words {
      let word = String(wordSub)
      if current.isEmpty {
        current = word
        continue
      }
      if current.count + 1 + word.count <= width {
        current += " " + word
      } else {
        lines.append(current)
        current = word
      }
    }

    if !current.isEmpty {
      lines.append(current)
    }

    return lines
  }

  private func matchPrefix(in line: String, pattern: String) -> String? {
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      return nil
    }
    let range = NSRange(line.startIndex..<line.endIndex, in: line)
    guard let match = regex.firstMatch(in: line, range: range) else {
      return nil
    }
    guard let matchRange = Range(match.range(at: 1), in: line) else {
      return nil
    }
    return String(line[matchRange])
  }
}

  
