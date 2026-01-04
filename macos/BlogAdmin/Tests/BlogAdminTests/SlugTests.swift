import XCTest
@testable import BlogAdmin

final class SlugTests: XCTestCase {
  func testSlugifyBasic() {
    XCTAssertEqual(Slug.make(from: "Hello, World!"), "hello-world")
  }

  func testSlugifyFallback() {
    XCTAssertEqual(Slug.make(from: "!!!"), "post")
  }

  func testSlugifyTrimsDashes() {
    XCTAssertEqual(Slug.make(from: " -- Example -- "), "example")
  }
}
