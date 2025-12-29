#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "time"
require "yaml"

ROOT = File.expand_path("..", __dir__)
POST_ROOTS = [
  File.join(ROOT, "src/posts/notes"),
  File.join(ROOT, "src/posts/links")
].freeze

CT_OFFSET = "-06:00"

def read_front_matter(path)
  content = File.read(path)
  lines = content.split("\n", -1)
  return [{}, content] unless lines.first&.strip == "---"

  end_index = lines[1..].index { |line| line.strip == "---" }
  return [{}, content] if end_index.nil?

  end_index += 1
  yaml_text = lines[1...end_index].join("\n")
  body = lines[(end_index + 1)..].join("\n")
  data = YAML.safe_load(yaml_text, permitted_classes: [Date, Time], aliases: true) || {}
  [data, body]
end

def indent_sequences(yaml)
  lines = yaml.split("\n", -1)
  output = []
  in_sequence_block = false

  lines.each do |line|
    trimmed = line.strip
    if trimmed.empty?
      output << line
      next
    end

    if trimmed.end_with?(":")
      output << line
      in_sequence_block = true
      next
    end

    if in_sequence_block && trimmed.start_with?("- ")
      output << (line.start_with?("  ") ? line : "  #{trimmed}")
      next
    end

    output << line
    in_sequence_block = false
  end

  output.join("\n")
end

def dump_front_matter(data, body)
  yaml = YAML.dump(data).sub(/\A---\s*\n/, "").sub(/\n\.\.\.\s*\n\z/, "\n")
  yaml = indent_sequences(yaml).strip
  ["---", yaml, "---", body].join("\n")
end

def date_from_path(path)
  if (match = path.match(%r{(\d{4})-(\d{2})-(\d{2})}))
    return "#{match[1]}-#{match[2]}-#{match[3]}"
  end
  nil
end

def iso8601_with_ct(value)
  text = value.to_s.strip
  return nil if text.empty?

  if text.match?(/^\d{4}-\d{2}-\d{2}$/)
    return "#{text}T09:00:00#{CT_OFFSET}"
  end

  if text.match?(/[zZ]|[+-]\d{2}:?\d{2}$/)
    return Time.parse(text).iso8601
  end

  if text.match?(/^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}/)
    return text.tr(" ", "T") + CT_OFFSET
  end

  Time.parse(text).iso8601
rescue ArgumentError
  nil
end

def slug_from_path(path)
  base = File.basename(path, ".md")
  return File.basename(File.dirname(path)) if base == "index"

  if (match = base.match(/^\d{4}-\d{2}-\d{2}-(.+)$/))
    return match[1]
  end

  if (match = path.match(%r{/\d{4}/\d{2}/([^/]+)/index\.md$}))
    return match[1]
  end
  base
end

def unique_path(path)
  return path unless File.exist?(path)

  ext = File.extname(path)
  base = File.basename(path, ext)
  dir = File.dirname(path)
  index = 2

  loop do
    candidate = File.join(dir, "#{base}-#{index}#{ext}")
    return candidate unless File.exist?(candidate)
    index += 1
  end
end

def move_post(path, date_iso)
  date = Time.parse(date_iso).getlocal(CT_OFFSET)
  year = date.strftime("%Y")
  month = date.strftime("%m")
  slug = slug_from_path(path)
  base_root = POST_ROOTS.find { |root| path.start_with?(root) }
  return nil unless base_root

  target_dir = File.join(base_root, year, month)
  FileUtils.mkdir_p(target_dir)

  if File.basename(path) == "index.md"
    source_folder = File.dirname(path)
    folder = File.join(target_dir, slug)
    folder = unique_path(folder)
    FileUtils.mkdir_p(File.dirname(folder))
    FileUtils.mv(source_folder, folder) unless source_folder == folder
    target = File.join(folder, "index.md")
  else
    target = File.join(target_dir, "#{slug}.md")
    target = unique_path(target)
    FileUtils.mkdir_p(File.dirname(target))
    FileUtils.mv(path, target) unless path == target
  end
  target
end

updated = 0
skipped = []

POST_ROOTS.each do |root|
  Dir.glob(File.join(root, "**/*.md")).each do |path|
    data, body = read_front_matter(path)
    raw_date = data["date"] || date_from_path(path)
    iso_date = iso8601_with_ct(raw_date)

    if iso_date.nil?
      skipped << path
      next
    end

    data["date"] = iso_date
    content = dump_front_matter(data, body)
    File.write(path, content)
    target = move_post(path, iso_date)
    updated += 1 if target
  end
end

puts "Updated #{updated} posts."
if skipped.any?
  puts "Skipped #{skipped.count} posts (no parsable date):"
  skipped.each { |path| puts "  - #{path}" }
end
