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
      } else {
        postImages = []
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
    .toolbar {
      ToolbarItemGroup {
        Button("New") { showNewPostSheet = true }
          .disabled(repoPath.isEmpty)
        Button("Reload") { repository.loadPosts() }
        Button("Save") { savePost() }
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
        DatePicker("Date", selection: dateBinding, displayedComponents: [.date])
        Picker("Category", selection: $editor.category) {
          Text("None").tag("")
          ForEach(categoryOptions, id: \.self) { category in
            Text(category).tag(category)
          }
        }
        .pickerStyle(.menu)
        TextField("Tags (comma separated)", text: $editor.tags)
        TextField("Subtitle", text: $editor.subtitle)
        TextField("Description", text: $editor.description)
        Picker("Image", selection: $editor.image) {
          Text("None").tag("")
          ForEach(imageOptions, id: \.self) { image in
            Text(image).tag(image)
          }
        }
        .pickerStyle(.menu)

        DisclosureGroup("Styles") {
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
            editor.modified = dateString(from: Date())
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
        editor.date = dateString(from: newValue)
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
    formatter.timeZone = TimeZone.current
    return formatter
  }()

  private func parseDate(_ value: String) -> Date? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    return dateFormatter.date(from: trimmed)
  }

  private func dateString(from date: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let year = components.year ?? 0
    let month = components.month ?? 1
    let day = components.day ?? 1
    return String(format: "%04d-%02d-%02d", year, month, day)
  }

  private var modifiedBinding: Binding<Date> {
    Binding(
      get: {
        parseDate(editor.modified) ?? Date()
      },
      set: { newValue in
        editor.modified = dateString(from: newValue)
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
    do {
      _ = Document(parsing: updated.body)
      let saved = try repository.save(post: updated, desiredDate: editor.date)
      selection = saved.id
      editor.load(post: saved)
      postImages = repository.images(for: saved)
    } catch {
      NSSound.beep()
    }
  }
}

  
