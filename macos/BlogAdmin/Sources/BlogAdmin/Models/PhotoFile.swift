import Foundation

struct PhotoFile: Identifiable, Hashable {
  let id: String
  let url: URL
  var title: String
  var comment: String
  var date: Date

  var sortDate: Date { date }

  static func load(from url: URL, metadata: ExifMetadata?) -> PhotoFile {
    let fallbackDate = (try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date) ?? Date.distantPast
    let title = metadata?.title?.trimmingCharacters(in: .whitespacesAndNewlines)
    let fallbackTitle = url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ")
    let resolvedTitle: String
    if let title, !title.isEmpty {
      resolvedTitle = title
    } else {
      resolvedTitle = fallbackTitle
    }
    let comment = metadata?.comment ?? ""
    let date = metadata?.date ?? fallbackDate
    return PhotoFile(id: url.path, url: url, title: resolvedTitle, comment: comment, date: date)
  }
}
