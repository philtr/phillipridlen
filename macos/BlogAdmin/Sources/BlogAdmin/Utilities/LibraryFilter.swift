import Foundation

enum LibraryFilter {
  static func posts(_ posts: [PostFile], query: String) -> [PostFile] {
    let normalized = normalize(query)
    guard !normalized.isEmpty else { return posts }
    return posts.filter { post in
      let tags = post.tags.joined(separator: " ")
      let filename = post.url.lastPathComponent
      return matches(normalized, in: [post.title, post.category, tags, filename])
    }
  }

  static func photos(_ photos: [PhotoFile], query: String) -> [PhotoFile] {
    let normalized = normalize(query)
    guard !normalized.isEmpty else { return photos }
    return photos.filter { photo in
      let filename = photo.url.lastPathComponent
      return matches(normalized, in: [photo.title, filename])
    }
  }

  private static func normalize(_ query: String) -> String {
    query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }

  private static func matches(_ query: String, in values: [String]) -> Bool {
    values.contains { value in
      value.lowercased().contains(query)
    }
  }
}
