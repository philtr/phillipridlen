import XCTest
@testable import BlogAdmin

final class FrontMatterTests: XCTestCase {
  func testDumpIndentsSequences() {
    let frontMatter = FrontMatter(data: [
      "styles": ["posts/image", "posts/journal"]
    ])

    let yaml = frontMatter.dump()

    XCTAssertTrue(
      yaml.contains("styles:\n  - posts/image\n  - posts/journal"),
      "Expected sequence items to be indented two spaces."
    )
  }

  func testParseKeepsISO8601DateString() {
    let content = """
    ---
    title: Test
    date: 2025-12-27T09:00:00-06:00
    ---
    Body
    """

    let (frontMatter, _) = FrontMatter.parse(from: content)
    let parsed = parseDate(frontMatter.string("date"))

    XCTAssertNotNil(parsed)
    XCTAssertEqual(isoString(from: parsed!), "2025-12-27T09:00:00-06:00")
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
