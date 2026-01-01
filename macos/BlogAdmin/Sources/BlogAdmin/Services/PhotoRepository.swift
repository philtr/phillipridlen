import Foundation

final class PhotoRepository: ObservableObject {
  @Published var photos: [PhotoFile] = []

  private var rootURL: URL? = nil
  private let photoExtensions: Set<String> = ["jpg"]

  func updateRoot(path: String) {
    let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed != "" else {
      rootURL = nil
      photos = []
      return
    }
    rootURL = URL(fileURLWithPath: trimmed)
    loadPhotos()
  }

  func loadPhotos() {
    guard let rootURL else {
      photos = []
      return
    }

    let photosRoot = rootURL.appendingPathComponent("src/photos")
    guard let files = listPhotoFiles(in: photosRoot) else {
      photos = []
      return
    }

    var loaded: [PhotoFile] = []
    for url in files {
      let metadata = ImageIOExif.readMetadata(from: url)
      loaded.append(PhotoFile.load(from: url, metadata: metadata))
    }

    photos = loaded.sorted { lhs, rhs in
      if lhs.sortDate != rhs.sortDate {
        return lhs.sortDate > rhs.sortDate
      }
      return lhs.title.lowercased() < rhs.title.lowercased()
    }
  }

  func save(photo: PhotoFile) throws -> PhotoFile {
    try ImageIOExif.writeMetadata(to: photo.url, title: photo.title, comment: photo.comment, date: photo.date)
    loadPhotos()
    if let updated = photos.first(where: { $0.url == photo.url }) {
      return updated
    }
    return photo
  }

  private func listPhotoFiles(in root: URL) -> [URL]? {
    guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else {
      return nil
    }

    var results: [URL] = []
    for case let url as URL in enumerator {
      let ext = url.pathExtension.lowercased()
      if photoExtensions.contains(ext) {
        results.append(url)
      }
    }
    return results
  }
}
