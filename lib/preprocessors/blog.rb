# Preprocessor helpers for blog-related items.
# Extracts metadata from filenames and creates category pages.
#
require "securerandom"

POST_REGEXES = [
  %r{\A/posts/(link|note)s/\d{4}/\d{2}/([^/]+)(?:/index)?\.md\z},
  %r{\A/posts/(link|note)s/\d{4}-\d{2}-\d{2}-([^/]+)(?:/index)?\.md\z}
].freeze
POST_ASSET_REGEXES = [
  %r{\A/posts/(link|note)s/\d{4}/\d{2}/([^/]+)/(.+)\z},
  %r{\A/posts/(link|note)s/\d{4}-\d{2}-\d{2}-([^/]+)/(.+)\z}
].freeze

def blog_post_items
  @blog_post_items ||= @items
    .find_all("/posts/**/*")
    .select { |item| POST_REGEXES.any? { |regex| item.identifier.to_s.match?(regex) } }
end

def blog_post_attributes_from_filename
  blog_post_items.each do |item|
    post_type, slug = post_type_and_slug_for(item.identifier.to_s)
    item[:post_type] = post_type
    item[:slug] = slug
  end
end

def blog_post_ids
  blog_post_items.each do |item|
    next unless item[:id].to_s.strip.empty?

    filename = item.respond_to?(:content_filename) ? item.content_filename : nil
    next unless filename && File.file?(filename)

    content = File.read(filename)
    updated_content, generated_id = ensure_post_id_in_content(content)
    next unless generated_id

    File.write(filename, updated_content)
    item[:id] = generated_id
  end
end

def blog_category_items
  blog_post_items
    .map { it[:category].to_s.downcase }
    .reject(&:empty?)
    .uniq
    .map { {name: it.titleize, slug: it.parameterize} }
    .map { @items.create("", it, "/categories/#{it[:slug]}") }
end

def blog_post_asset_attributes
  index = blog_post_index

  @items.find_all("/posts/**/*").each do |item|
    next if item.identifier.to_s.end_with?(".md")

    match = POST_ASSET_REGEXES.find { |regex| item.identifier.to_s.match?(regex) }
    next unless match

    post_type, slug, relative = item.identifier.to_s.match(match).captures
    parent = index["#{post_type}/#{slug}"]
    next unless parent

    item[:post_type] = parent[:post_type]
    item[:date] = parent[:date] if parent[:date]
    item[:slug] = parent[:slug]
    item[:category] = parent[:category]
    item[:relative_path] = relative
  end
end

def blog_post_date_for_drafts
  if @config[:drafts]
    @items.find_all("/drafts/**/*").each do |item|
      item[:date] = Time.now
    end
  end
end

def post_type_and_slug_for(identifier)
  POST_REGEXES.each do |regex|
    match = identifier.match(regex)
    next unless match
    post_type = match.captures[0]
    slug = match.captures[1]
    return [post_type, slug]
  end
  ["note", ""]
end

def blog_post_index
  @blog_post_index ||= blog_post_items.each_with_object({}) do |post, index|
    post_type = post[:post_type]
    slug = post[:slug]
    next if post_type.to_s.empty? || slug.to_s.empty?

    index["#{post_type}/#{slug}"] = post
  end
end

def ensure_post_id_in_content(content)
  lines = content.lines
  return [content, nil] if lines.empty? || lines.first.strip != "---"

  end_index = lines[1..].index { |line| line.strip == "---" }
  return [content, nil] unless end_index

  frontmatter_end = end_index + 1
  frontmatter_lines = lines[1...frontmatter_end]
  return [content, nil] if frontmatter_lines.any? { |line| line.match?(/\Aid:\s*/) }

  generated_id = SecureRandom.alphanumeric(26).upcase
  lines.insert(1, "id: #{generated_id}\n")
  [lines.join, generated_id]
end
