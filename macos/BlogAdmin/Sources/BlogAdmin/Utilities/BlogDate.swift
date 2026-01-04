import Foundation

enum BlogDate {
  private static let timeZone = TimeZone(identifier: "America/Chicago") ?? .current
  private static let locale = Locale(identifier: "en_US_POSIX")

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = locale
    formatter.timeZone = timeZone
    return formatter
  }()

  private static let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = locale
    formatter.timeZone = timeZone
    return formatter
  }()

  private static let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = timeZone
    return formatter
  }()

  static func parseDate(_ value: String) -> Date? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    if trimmed.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil {
      return dateAtNineAM(from: trimmed)
    }
    if let parsed = isoFormatter.date(from: trimmed) { return parsed }
    return dateTimeFormatter.date(from: trimmed) ?? dateFormatter.date(from: trimmed)
  }

  static func dateOnlyString(from date: Date) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let year = components.year ?? 0
    let month = components.month ?? 1
    let day = components.day ?? 1
    return String(format: "%04d-%02d-%02d", year, month, day)
  }

  static func dateTimeString(from date: Date, existing: String) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    components.timeZone = timeZone

    if components.hour == nil || components.minute == nil {
      if let existingTime = timeComponents(from: existing) {
        components.hour = existingTime.hour
        components.minute = existingTime.minute
        components.second = existingTime.second
      } else {
        components.hour = 9
        components.minute = 0
        components.second = 0
      }
    } else if components.second == nil {
      components.second = 0
    }

    let finalDate = calendar.date(from: components) ?? date
    return isoFormatter.string(from: finalDate)
  }

  static func normalizeDateOnlyString(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    if trimmed.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil {
      return trimmed
    }
    if let date = parseDate(trimmed) {
      return dateOnlyString(from: date)
    }
    return nil
  }

  static func normalizeDateInput(_ value: String) -> String {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed != "" else { return "" }
    if trimmed.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) == nil {
      return trimmed
    }
    if let date = dateAtNineAM(from: trimmed) {
      return isoFormatter.string(from: date)
    }
    return trimmed
  }

  static func defaultPostDate() -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    components.timeZone = timeZone
    components.hour = 9
    components.minute = 0
    components.second = 0
    return calendar.date(from: components) ?? Date()
  }

  static func iso8601String(from date: Date) -> String {
    let calendar = Calendar(identifier: .gregorian)
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    components.timeZone = timeZone
    if components.hour == nil || components.minute == nil {
      components.hour = 9
      components.minute = 0
      components.second = 0
    } else if components.second == nil {
      components.second = 0
    }
    let finalDate = calendar.date(from: components) ?? date
    return isoFormatter.string(from: finalDate)
  }

  private static func timeComponents(from value: String) -> (hour: Int, minute: Int, second: Int)? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.range(of: #"\d{2}:\d{2}"#, options: .regularExpression) != nil else {
      return nil
    }
    if let parsed = isoFormatter.date(from: trimmed) {
      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents(in: timeZone, from: parsed)
      return (components.hour ?? 9, components.minute ?? 0, components.second ?? 0)
    }
    if let parsed = dateTimeFormatter.date(from: trimmed) {
      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents([.hour, .minute, .second], from: parsed)
      return (components.hour ?? 9, components.minute ?? 0, components.second ?? 0)
    }
    return nil
  }

  private static func dateAtNineAM(from dateOnly: String) -> Date? {
    guard let base = dateFormatter.date(from: dateOnly) else { return nil }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var components = calendar.dateComponents([.year, .month, .day], from: base)
    components.timeZone = timeZone
    components.hour = 9
    components.minute = 0
    components.second = 0
    return calendar.date(from: components)
  }
}
