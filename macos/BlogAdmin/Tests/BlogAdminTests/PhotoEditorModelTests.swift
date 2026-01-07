import XCTest
@testable import BlogAdmin

final class PhotoEditorModelTests: XCTestCase {
  func testUpdatedPhotoTrimsTitle() {
    let url = URL(fileURLWithPath: "/tmp/photo.jpg")
    let photo = PhotoFile(id: url.path, url: url, title: "Original", comment: "", date: Date())

    let model = PhotoEditorModel()
    model.load(photo: photo)
    model.title = "  New Title  "

    guard let updated = model.updatedPhoto() else {
      XCTFail("Expected updated photo.")
      return
    }

    XCTAssertEqual(updated.title, "New Title")
  }
}
