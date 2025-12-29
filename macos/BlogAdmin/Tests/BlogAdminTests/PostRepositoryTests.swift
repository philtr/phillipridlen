import XCTest
@testable import BlogAdmin

final class PostRepositoryTests: XCTestCase {
  func testCreatePostUsesYearMonthFoldersAndISODate() throws {
    let tempRoot = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: tempRoot) }

    try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)

    let repository = PostRepository()
    repository.updateRoot(path: tempRoot.path)

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 27, hour: 12))!

    let post = try repository.createPost(
      title: "My Post",
      date: date,
      category: "",
      tags: [],
      excerpt: "",
      body: "Body",
      scope: .notes
    )

    XCTAssertTrue(
      post.url.path.contains("/src/posts/notes/2025/12/"),
      "Expected post path to include year/month folders."
    )

    let content = try String(contentsOf: post.url, encoding: .utf8)
    let (frontMatter, _) = FrontMatter.parse(from: content)
    let parsed = parseDate(frontMatter.string("date"))

    XCTAssertNotNil(parsed)
    XCTAssertTrue(
      isoString(from: parsed!).hasPrefix("2025-12-27T09:00:00-"),
      "Expected date to be ISO8601 with 9am CT."
    )
  }

  private func parseDate(_ value: String) -> Date? {
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime]
    if let date = iso.date(from: value) {
      return date
    }
    return DateFormatter.iso8601Fallback.date(from: value)
  }

  private func isoString(from date: Date) -> String {
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime]
    iso.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    return iso.string(from: date)
  }
}

private extension DateFormatter {
  static let iso8601Fallback: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
