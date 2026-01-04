import XCTest
@testable import BlogAdmin

final class PostEditorModelTests: XCTestCase {
  func testUpdatedPostNormalizesFields() {
    let url = URL(fileURLWithPath: "/tmp/post.md")
    let frontMatter = FrontMatter(data: ["title": "Original", "layout": "post"])
    let post = PostFile(id: url.path, url: url, frontMatter: frontMatter, body: "Body")

    let model = PostEditorModel()
    model.load(post: post)
    model.title = "Updated"
    model.date = "2024-03-12"
    model.tags = "swift, ,  macos  , "
    model.category = "   "
    model.description = "  "
    model.subtitle = ""
    model.image = " hero.png "
    model.isDraft = false

    guard let updated = model.updatedPost() else {
      XCTFail("Expected updated post.")
      return
    }

    XCTAssertEqual(updated.frontMatter.string("title"), "Updated")
    XCTAssertTrue(updated.frontMatter.string("date").hasPrefix("2024-03-12T"))
    XCTAssertEqual(updated.frontMatter.stringArray("tags"), ["swift", "macos"])
    XCTAssertEqual(updated.frontMatter.string("image"), "hero.png")
    XCTAssertFalse(updated.frontMatter.has("category"))
    XCTAssertFalse(updated.frontMatter.has("description"))
    XCTAssertFalse(updated.frontMatter.has("subtitle"))
    XCTAssertFalse(updated.frontMatter.has("draft"))
  }
}
