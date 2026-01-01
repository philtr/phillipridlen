import Foundation

final class PhotoEditorModel: ObservableObject {
  @Published var photo: PhotoFile? = nil
  @Published var title: String = ""
  @Published var comment: String = ""
  @Published var date: Date = Date()

  func load(photo: PhotoFile?) {
    self.photo = photo
    title = photo?.title ?? ""
    comment = photo?.comment ?? ""
    date = photo?.date ?? Date()
  }

  func updatedPhoto() -> PhotoFile? {
    guard var photo else { return nil }
    photo.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    photo.comment = comment
    photo.date = date
    return photo
  }
}
