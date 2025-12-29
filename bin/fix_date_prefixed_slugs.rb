#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

ROOT = File.expand_path("..", __dir__)
POST_ROOTS = [
  File.join(ROOT, "src/posts/notes"),
  File.join(ROOT, "src/posts/links")
].freeze

DATE_SLUG_REGEX = %r{\A(\d{4}-\d{2}-\d{2})-(.+)\z}.freeze

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

moved = 0
skipped = 0

POST_ROOTS.each do |root|
  Dir.glob(File.join(root, "**/index.md")).each do |path|
    folder = File.basename(File.dirname(path))
    match = folder.match(DATE_SLUG_REGEX)
    next unless match

    slug = match[2]
    target_dir = File.dirname(File.dirname(path))
    desired_folder = File.join(target_dir, slug)
    desired_folder = unique_path(desired_folder)

    if File.basename(File.dirname(path)) == File.basename(desired_folder)
      skipped += 1
      next
    end

    FileUtils.mv(File.dirname(path), desired_folder)
    moved += 1
  end

  Dir.glob(File.join(root, "**/*.md")).each do |path|
    next if File.basename(path) == "index.md"
    base = File.basename(path, ".md")
    match = base.match(DATE_SLUG_REGEX)
    next unless match

    slug = match[2]
    target_dir = File.dirname(path)
    desired = File.join(target_dir, "#{slug}.md")
    desired = unique_path(desired)

    if path == desired
      skipped += 1
      next
    end

    FileUtils.mv(path, desired)
    moved += 1
  end
end

puts "Moved #{moved} paths."
puts "Skipped #{skipped} paths." if skipped.positive?
