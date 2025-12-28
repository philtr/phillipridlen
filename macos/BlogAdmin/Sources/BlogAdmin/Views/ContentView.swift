import AppKit
import SwiftUI

struct ContentView: View {
  @AppStorage("repoPath") private var repoPath: String = ""
  @StateObject private var repository = PostRepository()
  @StateObject private var editor = PostEditorModel()
  @State private var selection: String? = nil

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
    }
    .toolbar {
      ToolbarItemGroup {
        Button("Choose Folder") { chooseFolder() }
        Button("Reload") { repository.loadPosts() }
        Button("Save") { savePost() }
          .disabled(editor.post == nil)
      }
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
    Group {
      if editor.post == nil {
        emptyState
      } else {
        editorForm
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(16)
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

      DisclosureGroup("Excerpt") {
        TextEditor(text: $editor.excerpt)
          .frame(minHeight: 120)
      }

      Section("Body") {
        TextEditor(text: $editor.body)
          .frame(minHeight: 360)
      }
    }
  }

  private var dateBinding: Binding<Date> {
    Binding(
      get: {
        parseDate(editor.date) ?? Date()
      },
      set: { newValue in
        editor.date = dateFormatter.string(from: newValue)
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

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()

  private func parseDate(_ value: String) -> Date? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    return dateFormatter.date(from: trimmed)
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

  private func chooseFolder() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.title = "Choose Blog Repository"

    if panel.runModal() == .OK, let url = panel.url {
      repoPath = url.path
    }
  }

  private func savePost() {
    guard let updated = editor.updatedPost() else { return }
    do {
      try repository.save(post: updated)
    } catch {
      NSSound.beep()
    }
  }
}
