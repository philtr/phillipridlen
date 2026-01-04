import Foundation

enum MarkdownWrap {
  static func hardWrap(text: String, width: Int) -> String {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    var output: [String] = []
    var paragraph: [String] = []
    var inCodeFence = false

    func flushParagraph() {
      guard !paragraph.isEmpty else { return }
      let firstLine = paragraph[0]
      let trimmedFirst = firstLine.trimmingCharacters(in: .whitespaces)

      if trimmedFirst.hasPrefix("#") && paragraph.count == 1 {
        output.append(firstLine)
        paragraph.removeAll()
        return
      }

      let blockquotePrefix = matchPrefix(in: firstLine, pattern: #"^(\s*>+\s+)"#)
      let listPrefix = matchPrefix(in: firstLine, pattern: #"^(\s*(?:[-*+]|\d+\.)\s+)"#)

      let prefix: String
      let continuationPrefix: String
      if let blockquotePrefix {
        prefix = blockquotePrefix
        continuationPrefix = blockquotePrefix
      } else if let listPrefix {
        prefix = listPrefix
        continuationPrefix = String(repeating: " ", count: listPrefix.count)
      } else {
        prefix = ""
        continuationPrefix = ""
      }

      let content = paragraph
        .map { line in
          if prefix != "", line.hasPrefix(prefix) {
            return String(line.dropFirst(prefix.count))
          }
          return line.trimmingCharacters(in: .whitespaces)
        }
        .joined(separator: " ")
        .trimmingCharacters(in: .whitespaces)

      let contentWidth = max(1, width - prefix.count)
      let wrappedLines = wrapText(content, width: contentWidth)

      for (index, line) in wrappedLines.enumerated() {
        if index == 0 {
          output.append(prefix + line)
        } else {
          output.append(continuationPrefix + line)
        }
      }

      paragraph.removeAll()
    }

    for rawLine in lines {
      let line = String(rawLine)
      let trimmed = line.trimmingCharacters(in: .whitespaces)

      if trimmed.hasPrefix("```") {
        flushParagraph()
        output.append(line)
        inCodeFence.toggle()
        continue
      }

      if inCodeFence {
        output.append(line)
        continue
      }

      if trimmed.range(of: #"^\s*\[[^\]]+\]:\s+\S+"#, options: .regularExpression) != nil {
        flushParagraph()
        output.append(line)
        continue
      }

      if trimmed.isEmpty {
        flushParagraph()
        output.append(line)
        continue
      }

      if line.hasPrefix("    ") || line.hasPrefix("\t") {
        flushParagraph()
        output.append(line)
        continue
      }

      paragraph.append(line)
    }

    flushParagraph()
    return output.joined(separator: "\n")
  }

  private static func wrapText(_ text: String, width: Int) -> [String] {
    let words = text.split(whereSeparator: { $0.isWhitespace })
    guard !words.isEmpty else { return [""] }

    var lines: [String] = []
    var current = ""

    for wordSub in words {
      let word = String(wordSub)
      if current.isEmpty {
        current = word
        continue
      }
      if current.count + 1 + word.count <= width {
        current += " " + word
      } else {
        lines.append(current)
        current = word
      }
    }

    if !current.isEmpty {
      lines.append(current)
    }

    return lines
  }

  private static func matchPrefix(in line: String, pattern: String) -> String? {
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      return nil
    }
    let range = NSRange(line.startIndex..<line.endIndex, in: line)
    guard let match = regex.firstMatch(in: line, range: range) else {
      return nil
    }
    guard let matchRange = Range(match.range(at: 1), in: line) else {
      return nil
    }
    return String(line[matchRange])
  }
}
