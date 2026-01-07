import XCTest
@testable import BlogAdmin

final class LibraryFilterTests: XCTestCase {
  func testPostFilteringMatchesTitleAndTags() {
    let url = URL(fileURLWithPath: "/tmp/post.md")
    let frontMatter = FrontMatter(data: [
      "title": "Hello World",
      "category": "Notes",
      "tags": ["swift", "macos"],
      "layout": "post"
    ])
    let post = PostFile(id: url.path, url: url, frontMatter: frontMatter, body: "")

    let byTitle = LibraryFilter.posts([post], query: "hello")
    XCTAssertEqual(byTitle.count, 1)

    let byTag = LibraryFilter.posts([post], query: "macos")
    XCTAssertEqual(byTag.count, 1)

    let miss = LibraryFilter.posts([post], query: "python")
    XCTAssertTrue(miss.isEmpty)
  }

  func testPhotoFilteringMatchesTitleAndFilename() {
    let url = URL(fileURLWithPath: "/tmp/sunset-view.jpg")
    let photo = PhotoFile(id: url.path, url: url, title: "Sunset View", comment: "", date: Date())

    let byTitle = LibraryFilter.photos([photo], query: "sunset")
    XCTAssertEqual(byTitle.count, 1)

    let byFilename = LibraryFilter.photos([photo], query: "view.jpg")
    XCTAssertEqual(byFilename.count, 1)

    let miss = LibraryFilter.photos([photo], query: "forest")
    XCTAssertTrue(miss.isEmpty)
  }
}
