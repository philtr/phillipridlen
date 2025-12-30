import Foundation

struct PostFile: Identifiable, Hashable {
  let id: String
  let url: URL
  var frontMatter: FrontMatter
  var body: String

  var title: String { frontMatter.string("title") }
  var date: String { frontMatter.string("date") }
  var category: String { frontMatter.string("category") }
  var tags: [String] { frontMatter.stringArray("tags") }
  var excerpt: String { frontMatter.string("excerpt") }
  var postType: String {
    let value = frontMatter.string("type")
    return value.isEmpty ? inferredTypeFromPath() : value
  }
  var isDraft: Bool {
    frontMatter.bool("draft") || url.path.contains("/src/drafts/")
  }

  var isFolderBased: Bool {
    url.lastPathComponent.lowercased() == "index.md"
  }

  var folderURL: URL {
    if isFolderBased {
      return url.deletingLastPathComponent()
    }
    return url.deletingLastPathComponent()
      .appendingPathComponent(url.deletingPathExtension().lastPathComponent)
  }

  var resolvedDateString: String {
    let trimmed = date.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed != "" {
      return trimmed
    }
    return fallbackDateStringFromPath() ?? ""
  }

  var sortDate: Date {
    if let parsed = PostFile.parseDate(resolvedDateString) {
      return parsed
    }
    return Date.distantPast
  }

  static func load(from url: URL) throws -> PostFile {
    let content = try String(contentsOf: url, encoding: .utf8)
    let (frontMatter, body) = FrontMatter.parse(from: content)
    return PostFile(id: url.path, url: url, frontMatter: frontMatter, body: body)
  }

  func renderedContent() -> String {
    var output = frontMatter.dump()
    let bodyText = body.hasSuffix("\n") ? body : body + "\n"
    output.append(bodyText)
    return output
  }

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()

  private static let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  private static let dateTimeFormatterNoZone: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  private static let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  private static let isoFormatterNoFraction: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()

  private static func parseDate(_ value: String) -> Date? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed == "" { return nil }
    if let parsed = dateFormatter.date(from: trimmed) { return parsed }
    if let parsed = dateTimeFormatter.date(from: trimmed) { return parsed }
    if let parsed = dateTimeFormatterNoZone.date(from: trimmed) { return parsed }
    if let parsed = isoFormatter.date(from: trimmed) { return parsed }
    if let parsed = isoFormatterNoFraction.date(from: trimmed) { return parsed }
    return nil
  }

  private func inferredTypeFromPath() -> String {
    if url.path.contains("/src/posts/links/") {
      return "link"
    }
    return "note"
  }

  private func fallbackDateStringFromPath() -> String? {
    let regex = try? NSRegularExpression(pattern: #"\d{4}-\d{2}-\d{2}"#)
    guard let regex else { return nil }
    let path = url.path
    let range = NSRange(path.startIndex..<path.endIndex, in: path)
    if let match = regex.firstMatch(in: path, range: range),
       let matchRange = Range(match.range, in: path) {
      return String(path[matchRange])
    }
    return nil
  }

  static func == (lhs: PostFile, rhs: PostFile) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
