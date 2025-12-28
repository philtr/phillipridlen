import Foundation

final class PostEditorModel: ObservableObject {
  @Published var post: PostFile? = nil
  @Published var title: String = ""
  @Published var date: String = ""
  @Published var category: String = ""
  @Published var tags: String = ""
  @Published var excerpt: String = ""
  @Published var body: String = ""

  func load(post: PostFile?) {
    self.post = post
    title = post?.title ?? ""
    date = post?.resolvedDateString ?? ""
    category = post?.category ?? ""
    tags = post?.tags.joined(separator: ", ") ?? ""
    excerpt = post?.excerpt ?? ""
    body = post?.body ?? ""
  }

  func updatedPost() -> PostFile? {
    guard var post else { return nil }
    var frontMatter = post.frontMatter

    frontMatter.set("title", value: title)
    let trimmedDate = date.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedDate == "" {
      if let fallback = post.filenameDateString {
        frontMatter.set("date", value: fallback)
      } else {
        frontMatter.remove("date")
      }
    } else {
      frontMatter.set("date", value: trimmedDate)
    }

    if category.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      frontMatter.remove("category")
    } else {
      frontMatter.set("category", value: category)
    }

    let tagsList = tags
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { $0 != "" }

    if tagsList.isEmpty {
      frontMatter.remove("tags")
    } else {
      frontMatter.set("tags", value: tagsList)
    }

    if excerpt.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      frontMatter.remove("excerpt")
    } else {
      frontMatter.set("excerpt", value: excerpt)
    }

    post.frontMatter = frontMatter
    post.body = body
    return post
  }
}
