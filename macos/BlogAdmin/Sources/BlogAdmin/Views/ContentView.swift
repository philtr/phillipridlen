import AppKit
import Markdown
import SwiftUI
import UniformTypeIdentifiers
import Yams

struct ContentView: View {
  private enum SidebarScope: String, CaseIterable, Identifiable {
    case posts
    case photos

    var id: String { rawValue }
  }

  @AppStorage("repoPath") private var repoPath: String = ""
  @StateObject private var repository = PostRepository()
  @StateObject private var editor = PostEditorModel()
  @StateObject private var photoRepository = PhotoRepository()
  @StateObject private var photoEditor = PhotoEditorModel()
  @State private var selection: String? = nil
  @State private var photoSelection: String? = nil
  @State private var sidebarScope: SidebarScope = .posts
  @State private var searchText: String = ""
  @State private var showNewPostSheet = false
  @State private var newTitle = ""
  @State private var newDate = BlogDate.defaultPostDate()
  @State private var newCategory = ""
  @State private var newTags = ""
  @State private var newPostType = "note"
  @State private var newDraft = false
  @State private var showImageImporter = false
  @State private var postImages: [URL] = []
  @State private var siteTitle: String = ""
  @State private var siteURL: String = ""
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
      photoRepository.updateRoot(path: repoPath)
      loadSiteInfo(from: repoPath)
      updateCanSave()
    }
    .onChange(of: repoPath) { newValue in
      repository.updateRoot(path: newValue)
      photoRepository.updateRoot(path: newValue)
      selection = nil
      editor.load(post: nil)
      photoSelection = nil
      photoEditor.load(photo: nil)
      searchText = ""
      loadSiteInfo(from: newValue)
      updateCanSave()
    }
    .onChange(of: selection) { newValue in
      let post = repository.posts.first { $0.id == newValue }
      editor.load(post: post)
      if let post {
        postImages = repository.images(for: post)
        originalTitle = post.title
        originalSlug = currentSlug(for: post)
      } else {
        postImages = []
        originalTitle = ""
        originalSlug = ""
      }
      updateCanSave()
    }
    .onChange(of: photoSelection) { newValue in
      let photo = photoRepository.photos.first { $0.id == newValue }
      photoEditor.load(photo: photo)
      updateCanSave()
    }
    .onChange(of: sidebarScope) { _ in
      searchText = ""
      updateCanSave()
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
      saveActiveItem()
    }
    .confirmationDialog(
      "Rename file to match title?",
      isPresented: $showRenameSlugPrompt,
      titleVisibility: .visible
    ) {
      Button("Rename") {
        guard let post = pendingSavePost else { return }
        performSave(post, desiredDate: pendingSaveDate, desiredSlug: pendingRenameSlug, desiredDraft: editor.isDraft)
      }
      Button("Keep Current Name") {
        guard let post = pendingSavePost else { return }
        performSave(post, desiredDate: pendingSaveDate, desiredSlug: nil, desiredDraft: editor.isDraft)
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
          photoRepository.loadPhotos()
        } label: {
          Label("Reload", systemImage: "arrow.clockwise")
        }
        .labelStyle(.iconOnly)
        .help("Reload Posts")

        Button {
          saveActiveItem()
        } label: {
          Label("Save", systemImage: "document.circle")
        }
        .labelStyle(.iconOnly)
        .help("Save Post")
        .disabled(!canSave)
      }
    }
    .navigationTitle(siteTitle.isEmpty ? "BlogAdmin" : siteTitle)
    .navigationSubtitle(siteURL)
    .sheet(isPresented: $showNewPostSheet) {
      newPostSheet
    }
  }

  private var sidebar: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Spacer()
        HStack(spacing: 4) {
          sidebarScopeButton(title: "Notes", systemImage: "doc.text", scope: .posts)
          sidebarScopeButton(title: "Photos", systemImage: "photo", scope: .photos)
        }
        .padding(4)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        Spacer()
      }

      TextField(searchPrompt, text: $searchText)
        .textFieldStyle(.roundedBorder)

      if sidebarScope == .posts {
        postsList
      } else {
        photosList
      }
    }
    .padding(12)
  }

  private var detail: some View {
    ScrollView {
      Group {
        if sidebarScope == .posts {
          if editor.post == nil {
            emptyState
          } else {
            editorForm
          }
        } else {
          if photoEditor.photo == nil {
            photosEmptyState
          } else {
            photoEditorForm
          }
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

  private var photosEmptyState: some View {
    VStack(spacing: 12) {
      Text("Select a photo to edit")
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
        DatePicker("Date", selection: dateBinding, displayedComponents: [.date, .hourAndMinute])
        Text("Times are saved in US Central time (America/Chicago).")
          .font(.caption)
          .foregroundStyle(.secondary)
        Picker("Type", selection: $editor.postType) {
          Text("Note").tag("note")
          Text("Link").tag("link")
        }
        .pickerStyle(.segmented)
        Toggle("Draft", isOn: $editor.isDraft)
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
            editor.modified = BlogDate.dateOnlyString(from: Date())
          }
        } else {
          HStack {
            DatePicker("Modified", selection: modifiedBinding, displayedComponents: [.date, .hourAndMinute])
            Button("Clear") { editor.modified = "" }
          }
          Text("Times are saved in US Central time (America/Chicago).")
            .font(.caption)
            .foregroundStyle(.secondary)
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

  private var photoEditorForm: some View {
    VStack(spacing: 12) {
      Form {
        TextField("Title", text: $photoEditor.title)
        DatePicker("Date", selection: $photoEditor.date, displayedComponents: [.date, .hourAndMinute])
      }

      if let photo = photoEditor.photo, let image = NSImage(contentsOf: photo.url) {
        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxWidth: 520)
          .cornerRadius(6)
          .shadow(radius: 1)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Comment")
          .font(.headline)
        TextEditor(text: $photoEditor.comment)
          .frame(minHeight: 200)
          .font(.system(size: 15))
          .lineSpacing(4)
          .padding(6)
          .background(Color(nsColor: .textBackgroundColor))
          .cornerRadius(6)
      }

      HStack {
        Button("Reveal in Finder") {
          if let photo = photoEditor.photo {
            NSWorkspace.shared.activateFileViewerSelecting([photo.url])
          }
        }
        Spacer()
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.bottom, 12)
  }

  private var newPostSheet: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("New Post")
        .font(.title2)

      TextField("Title", text: $newTitle)
      DatePicker("Date", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
      Text("Times are saved in US Central time (America/Chicago).")
        .font(.caption)
        .foregroundStyle(.secondary)
      Picker("Type", selection: $newPostType) {
        Text("Note").tag("note")
        Text("Link").tag("link")
      }
      .pickerStyle(.segmented)
      Toggle("Draft", isOn: $newDraft)
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
        BlogDate.parseDate(editor.date) ?? Date()
      },
      set: { newValue in
        editor.date = BlogDate.dateTimeString(from: newValue, existing: editor.date)
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

  private var modifiedBinding: Binding<Date> {
    Binding(
      get: {
        BlogDate.parseDate(editor.modified) ?? Date()
      },
      set: { newValue in
        editor.modified = BlogDate.dateTimeString(from: newValue, existing: editor.modified)
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
        postType: newPostType,
        draft: newDraft
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
    newDate = BlogDate.defaultPostDate()
    newCategory = ""
    newTags = ""
    newPostType = "note"
    newDraft = false
  }

  

  

  private struct PostGroup {
    let monthStart: Date
    let title: String
    let posts: [PostFile]
  }

  private struct PhotoGroup {
    let year: Int
    let title: String
    let photos: [PhotoFile]
  }

  private var searchPrompt: String {
    sidebarScope == .posts ? "Filter posts" : "Filter photos"
  }

  private var filteredPosts: [PostFile] {
    LibraryFilter.posts(repository.posts, query: searchText)
  }

  private var filteredPhotos: [PhotoFile] {
    LibraryFilter.photos(photoRepository.photos, query: searchText)
  }

  private var groupedPosts: [PostGroup] {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    formatter.locale = Locale.current
    let drafts = filteredPosts.filter { $0.isDraft }.sorted { $0.sortDate > $1.sortDate }
    let published = filteredPosts.filter { !$0.isDraft }
    let groups = Dictionary(grouping: published) { post in
      let date = post.sortDate
      return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? Date.distantPast
    }

    var results: [PostGroup] = []
    if !drafts.isEmpty {
      results.append(PostGroup(monthStart: Date.distantFuture, title: "Drafts", posts: drafts))
    }

    results.append(
      contentsOf: groups.keys.sorted(by: >).map { key in
        let posts = groups[key, default: []].sorted { $0.sortDate > $1.sortDate }
        return PostGroup(monthStart: key, title: formatter.string(from: key), posts: posts)
      }
    )

    return results
  }

  private var groupedPhotos: [PhotoGroup] {
    let calendar = Calendar.current
    let groups = Dictionary(grouping: filteredPhotos) { photo in
      calendar.component(.year, from: photo.sortDate)
    }

    return groups.keys.sorted(by: >).map { year in
      let photos = groups[year, default: []].sorted { $0.sortDate > $1.sortDate }
      return PhotoGroup(year: year, title: String(year), photos: photos)
    }
  }


  private func saveActiveItem() {
    if sidebarScope == .photos {
      savePhoto()
      return
    }

    let effectiveDate = ensureEditorDate()
    guard let updated = editor.updatedPost() else { return }
    let desiredSlug = Slug.make(from: editor.title)
    let titleChanged = editor.title != originalTitle
    if titleChanged && desiredSlug != "" && desiredSlug != currentSlug(for: updated) {
      pendingSavePost = updated
      pendingRenameSlug = desiredSlug
      pendingSaveDate = effectiveDate
      showRenameSlugPrompt = true
      return
    }

    performSave(updated, desiredDate: effectiveDate, desiredSlug: nil, desiredDraft: editor.isDraft)
  }

  private func performSave(_ post: PostFile, desiredDate: String, desiredSlug: String?, desiredDraft: Bool?) {
    do {
      var wrapped = post
      wrapped.body = MarkdownWrap.hardWrap(text: post.body, width: 80)
      editor.body = wrapped.body
      _ = Document(parsing: post.body)
      let saved = try repository.save(
        post: wrapped,
        desiredDate: desiredDate,
        desiredSlug: desiredSlug,
        desiredDraft: desiredDraft
      )
      selection = saved.id
      editor.load(post: saved)
      postImages = repository.images(for: saved)
      originalTitle = saved.title
      originalSlug = currentSlug(for: saved)
    } catch {
      NSSound.beep()
    }
  }

  private func savePhoto() {
    guard let updated = photoEditor.updatedPhoto() else { return }
    do {
      let saved = try photoRepository.save(photo: updated)
      photoEditor.load(photo: saved)
      photoSelection = saved.id
      updateCanSave()
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

  private func loadSiteInfo(from rootPath: String) {
    siteTitle = ""
    siteURL = ""
    let trimmed = rootPath.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    let configURL = URL(fileURLWithPath: trimmed).appendingPathComponent("nanoc.yaml")
    guard let yaml = try? String(contentsOf: configURL, encoding: .utf8) else { return }
    guard let data = try? Yams.load(yaml: yaml) as? [String: Any] else { return }
    guard let site = data["site"] as? [String: Any] else { return }
    siteTitle = site["site_name"] as? String ?? ""
    siteURL = site["base_url"] as? String ?? ""
  }

  

  private var postsList: some View {
    List(selection: $selection) {
      if filteredPosts.isEmpty {
        Text("No posts match.")
          .foregroundStyle(.secondary)
      }
      ForEach(groupedPosts, id: \.monthStart) { group in
        Section("\(group.title) (\(group.posts.count))") {
          ForEach(group.posts) { post in
            HStack(spacing: 8) {
              Image(systemName: post.postType == "link" ? "link" : "doc.text")
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

  private var photosList: some View {
    List(selection: $photoSelection) {
      if filteredPhotos.isEmpty {
        Text("No photos match.")
          .foregroundStyle(.secondary)
      }
      ForEach(groupedPhotos, id: \.year) { group in
        Section("\(group.title) (\(group.photos.count))") {
          ForEach(group.photos) { photo in
            HStack(spacing: 8) {
              Image(systemName: "photo")
                .foregroundStyle(.secondary)
              Text(photo.title.isEmpty ? "(Untitled)" : photo.title)
            }
            .tag(photo.id)
            .contextMenu {
              Button("Edit") {
                photoSelection = photo.id
              }
              Button("Show in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([photo.url])
              }
            }
          }
        }
      }
    }
    .listStyle(.sidebar)
  }

  private var canSave: Bool {
    switch sidebarScope {
    case .posts:
      return editor.post != nil
    case .photos:
      return photoEditor.photo != nil
    }
  }

  private func updateCanSave() {
    UserDefaults.standard.set(canSave, forKey: "BlogAdminCanSave")
  }

  private func ensureEditorDate() -> String {
    if editor.date.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      editor.date = BlogDate.dateTimeString(from: BlogDate.defaultPostDate(), existing: "")
    }
    return editor.date
  }

  private func sidebarScopeButton(title: String, systemImage: String, scope: SidebarScope) -> some View {
    Button {
      sidebarScope = scope
    } label: {
      Label(title, systemImage: systemImage)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(sidebarScope == scope ? Color.white : Color.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(minWidth: 76)
    }
    .buttonStyle(.plain)
    .background(sidebarScope == scope ? Color.accentColor : Color.clear)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }
}

  
