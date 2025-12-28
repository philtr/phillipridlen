import Foundation
import Yams

struct FrontMatter {
  private(set) var data: [String: Any]

  init(data: [String: Any]) {
    self.data = data
  }

  static func parse(from content: String) -> (FrontMatter, String) {
    let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
    guard lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) == "---" else {
      return (FrontMatter(data: [:]), content)
    }

    var endIndex: Int? = nil
    for index in 1..<lines.count {
      if lines[index].trimmingCharacters(in: .whitespacesAndNewlines) == "---" {
        endIndex = index
        break
      }
    }

    guard let end = endIndex else {
      return (FrontMatter(data: [:]), content)
    }

    let yamlLines = lines[1..<end].joined(separator: "\n")
    let bodyLines = lines[(end + 1)...].joined(separator: "\n")

    let parsed = FrontMatter.loadYaml(yamlLines)
    return (FrontMatter(data: parsed), bodyLines)
  }

  func string(_ key: String) -> String {
    if let value = data[key] as? String {
      return value
    }
    if let value = data[key] {
      return String(describing: value)
    }
    return ""
  }

  func stringArray(_ key: String) -> [String] {
    if let value = data[key] as? [String] {
      return value
    }
    if let value = data[key] as? [Any] {
      return value.map { String(describing: $0) }
    }
    return []
  }

  mutating func set(_ key: String, value: String) {
    data[key] = value
  }

  mutating func set(_ key: String, value: [String]) {
    data[key] = value
  }

  mutating func remove(_ key: String) {
    data.removeValue(forKey: key)
  }

  func dump() -> String {
    let yaml = (try? Yams.dump(object: data))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let parts = ["---", yaml, "---"]
    return parts.joined(separator: "\n") + "\n"
  }

  private static func loadYaml(_ yaml: String) -> [String: Any] {
    guard let loaded = try? Yams.load(yaml: yaml) else {
      return [:]
    }
    return normalize(loaded)
  }

  private static func normalize(_ value: Any) -> [String: Any] {
    if let dict = value as? [String: Any] {
      return dict
    }
    if let dict = value as? [AnyHashable: Any] {
      var converted: [String: Any] = [:]
      for (key, value) in dict {
        converted[String(describing: key)] = normalizeValue(value)
      }
      return converted
    }
    return [:]
  }

  private static func normalizeValue(_ value: Any) -> Any {
    if let dict = value as? [AnyHashable: Any] {
      var converted: [String: Any] = [:]
      for (key, value) in dict {
        converted[String(describing: key)] = normalizeValue(value)
      }
      return converted
    }
    if let array = value as? [Any] {
      return array.map { normalizeValue($0) }
    }
    return value
  }
}
