import Foundation
import ImageIO

struct ExifMetadata {
  let title: String?
  let comment: String?
  let date: Date?
}

enum ImageIOExif {
  private static let exifDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    return formatter
  }()

  static func readMetadata(from url: URL) -> ExifMetadata? {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
      return nil
    }

    let metadata = CGImageSourceCopyMetadataAtIndex(source, 0, nil)
    let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
    let exif = props?[kCGImagePropertyExifDictionary as String] as? [String: Any]
    let tiff = props?[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
    let iptc = props?[kCGImagePropertyIPTCDictionary as String] as? [String: Any]

    let title =
      iptc?[kCGImagePropertyIPTCHeadline as String] as? String ??
      (tiff?[kCGImagePropertyTIFFImageDescription as String] as? String) ??
      (tiff?["ImageDescription"] as? String)
    let comment =
      iptc?[kCGImagePropertyIPTCCaptionAbstract as String] as? String ??
      exifUserComment(exif?[kCGImagePropertyExifUserComment as String])
    let dateString =
      (exif?[kCGImagePropertyExifDateTimeOriginal as String] as? String) ??
      (tiff?[kCGImagePropertyTIFFDateTime as String] as? String) ??
      metadataString(metadata, path: "{Exif}DateTimeOriginal") ??
      metadataString(metadata, path: "{TIFF}DateTime")
    let date = dateString.flatMap { exifDateFormatter.date(from: $0) }

    return ExifMetadata(title: title, comment: comment, date: date)
  }

  static func writeMetadata(to url: URL, title: String, comment: String, date: Date) throws {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
      throw NSError(domain: "BlogAdmin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to read image source"])
    }
    guard let type = CGImageSourceGetType(source) else {
      throw NSError(domain: "BlogAdmin", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown image type"])
    }

    var props = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]) ?? [:]
    var exif = (props[kCGImagePropertyExifDictionary as String] as? [String: Any]) ?? [:]
    var tiff = (props[kCGImagePropertyTIFFDictionary as String] as? [String: Any]) ?? [:]
    var iptc = (props[kCGImagePropertyIPTCDictionary as String] as? [String: Any]) ?? [:]

    let dateString = exifDateFormatter.string(from: date)
    tiff[kCGImagePropertyTIFFImageDescription as String] = title
    tiff[kCGImagePropertyTIFFDateTime as String] = dateString
    exif[kCGImagePropertyExifDateTimeOriginal as String] = dateString
    iptc[kCGImagePropertyIPTCHeadline as String] = title
    iptc[kCGImagePropertyIPTCCaptionAbstract as String] = comment

    props[kCGImagePropertyExifDictionary as String] = exif
    props[kCGImagePropertyTIFFDictionary as String] = tiff
    props[kCGImagePropertyIPTCDictionary as String] = iptc

    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
      throw NSError(domain: "BlogAdmin", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to create image destination"])
    }

    CGImageDestinationAddImageFromSource(destination, source, 0, props as CFDictionary)
    if !CGImageDestinationFinalize(destination) {
      throw NSError(domain: "BlogAdmin", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to write image metadata"])
    }
  }

  private static func metadataString(_ metadata: CGImageMetadata?, path: String) -> String? {
    guard let metadata else { return nil }
    return CGImageMetadataCopyStringValueWithPath(metadata, nil, path as CFString) as String?
  }

  private static func metadataTagValue(_ metadata: CGImageMetadata?, namespace: String, name: String) -> String? {
    guard let metadata else { return nil }
    guard let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag] else {
      return nil
    }
    for tag in tags {
      let tagName = CGImageMetadataTagCopyName(tag) as String?
      let tagNamespace = CGImageMetadataTagCopyNamespace(tag) as String?
      guard tagName == name, tagNamespace == namespace else { continue }
      if let value = CGImageMetadataTagCopyValue(tag) {
        if let string = value as? String {
          return string
        }
        if let number = value as? NSNumber {
          return number.stringValue
        }
      }
    }
    return nil
  }

  private static func exifUserComment(_ value: Any?) -> String? {
    if let string = value as? String {
      return string
    }
    if let data = value as? Data {
      return decodeExifUserComment(data)
    }
    return nil
  }

  private static func decodeExifUserComment(_ data: Data) -> String? {
    guard data.count >= 8 else {
      return String(data: data, encoding: .utf8)
    }

    let prefix = data.prefix(8)
    let payload = data.dropFirst(8)
    let prefixString = String(data: prefix, encoding: .ascii) ?? ""

    if prefixString.hasPrefix("ASCII") {
      return String(data: payload, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
    }
    if prefixString.hasPrefix("UNICODE") {
      return String(data: payload, encoding: .utf16)?.trimmingCharacters(in: .controlCharacters)
    }
    if prefixString.hasPrefix("JIS") {
      return String(data: payload, encoding: .japaneseEUC)?.trimmingCharacters(in: .controlCharacters)
    }

    return String(data: data, encoding: .utf8)
  }
}
