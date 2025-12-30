import Foundation

final class PostEditorModel: ObservableObject {
  @Published var post: PostFile? = nil
  @Published var title: String = ""
  @Published var date: String = ""
  @Published var category: String = ""
  @Published var tags: String = ""
  @Published var description: String = ""
  @Published var subtitle: String = ""
  @Published var image: String = ""
  @Published var styles: [String] = []
  @Published var modified: String = ""
  @Published var body: String = ""

  func load(post: PostFile?) {
    self.post = post
    title = post?.title ?? ""
    date = post?.resolvedDateString ?? ""
    category = post?.category ?? ""
    tags = post?.tags.joined(separator: ", ") ?? ""
    description = post?.frontMatter.string("description") ?? ""
    subtitle = post?.frontMatter.string("subtitle") ?? ""
    image = post?.frontMatter.string("image") ?? ""
    styles = post?.frontMatter.stringArray("styles") ?? []
    modified = post?.frontMatter.string("modified") ?? ""
    body = post?.body ?? ""
  }

  func updatedPost() -> PostFile? {
    guard var post else { return nil }
    var frontMatter = post.frontMatter

    frontMatter.set("title", value: title)
    let dateText = normalizeDate(date)
    if dateText == "" {
      frontMatter.remove("date")
    } else {
      frontMatter.set("date", value: dateText)
    }

    if category.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      frontMatter.remove("category")
    } else {
      frontMatter.set("category", value: category)
    }

    let tagsList = tags
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { $0 != "" }

    if tagsList.isEmpty {
      frontMatter.remove("tags")
    } else {
      frontMatter.set("tags", value: tagsList)
    }

    let descriptionText = description.trimmingCharacters(in: .whitespacesAndNewlines)
    if descriptionText == "" {
      frontMatter.remove("description")
    } else {
      frontMatter.set("description", value: descriptionText)
    }

    let subtitleText = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
    if subtitleText == "" {
      frontMatter.remove("subtitle")
    } else {
      frontMatter.set("subtitle", value: subtitleText)
    }

    let imageText = image.trimmingCharacters(in: .whitespacesAndNewlines)
    if imageText == "" {
      frontMatter.remove("image")
    } else {
      frontMatter.set("image", value: imageText)
    }

    let stylesList = styles
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { $0 != "" }

    if stylesList.isEmpty {
      frontMatter.remove("styles")
    } else {
      frontMatter.set("styles", value: stylesList)
    }

    let modifiedText = modified.trimmingCharacters(in: .whitespacesAndNewlines)
    if modifiedText == "" {
      frontMatter.remove("modified")
    } else {
      frontMatter.set("modified", value: modifiedText)
    }

    post.frontMatter = frontMatter
    post.body = body
    return post
  }

  private func normalizeDate(_ value: String) -> String {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed != "" else { return "" }
    if trimmed.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) == nil {
      return trimmed
    }

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    let calendar = Calendar(identifier: .gregorian)
    let timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    if let parsed = dateFormatter.date(from: trimmed) {
      components = calendar.dateComponents([.year, .month, .day], from: parsed)
    }
    components.timeZone = timeZone
    components.hour = 9
    components.minute = 0
    components.second = 0
    let finalDate = calendar.date(from: components) ?? Date()
    return formatter.string(from: finalDate)
  }

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    return formatter
  }()
}
