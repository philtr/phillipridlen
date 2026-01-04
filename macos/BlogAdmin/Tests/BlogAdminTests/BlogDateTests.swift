import XCTest
@testable import BlogAdmin

final class BlogDateTests: XCTestCase {
  func testParseDateUsesNineAMForDateOnly() {
    guard let date = BlogDate.parseDate("2024-02-20") else {
      XCTFail("Expected date to parse.")
      return
    }

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Chicago") ?? .current
    let components = calendar.dateComponents([.hour, .minute, .second], from: date)

    XCTAssertEqual(components.hour, 9)
    XCTAssertEqual(components.minute, 0)
    XCTAssertEqual(components.second, 0)
  }

  func testNormalizeDateOnlyStringFromIsoDate() {
    let normalized = BlogDate.normalizeDateOnlyString("2024-02-20T10:15:00-06:00")
    XCTAssertEqual(normalized, "2024-02-20")
  }

  func testNormalizeDateInputFromDateOnly() {
    let normalized = BlogDate.normalizeDateInput("2024-02-20")
    XCTAssertTrue(normalized.hasPrefix("2024-02-20T"))
  }
}
