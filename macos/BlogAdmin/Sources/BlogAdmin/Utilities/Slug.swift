import Foundation

enum Slug {
  static func make(from input: String) -> String {
    let folded = input.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    var result = ""
    var lastWasDash = false

    for scalar in folded.unicodeScalars {
      if CharacterSet.alphanumerics.contains(scalar) {
        result.append(Character(scalar).lowercased())
        lastWasDash = false
      } else if !lastWasDash {
        result.append("-")
        lastWasDash = true
      }
    }

    let trimmed = result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    return trimmed.isEmpty ? "post" : trimmed
  }
}
