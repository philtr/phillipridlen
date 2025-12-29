# Preprocessor helpers for blog-related items.
# Extracts metadata from filenames and creates category pages.
#
POST_REGEXES = [
  %r{\A/posts/(link|note)s/\d{4}/\d{2}/([^/]+)(?:/index)?\.md\z},
  %r{\A/posts/(link|note)s/\d{4}-\d{2}-\d{2}-([^/]+)(?:/index)?\.md\z}
].freeze

def blog_post_items
  @items.find_all do |item|
    POST_REGEXES.any? { |regex| item.identifier.to_s.match?(regex) }
  end
end

def blog_post_attributes_from_filename
  blog_post_items.each do |item|
    post_type, slug = post_type_and_slug_for(item.identifier.to_s)
    item[:post_type] = post_type
    item[:slug] = slug
  end
end

def blog_category_items
  blog_post_items
    .map { it[:category].downcase }.uniq
    .map { {name: it.titleize, slug: it.parameterize} }
    .map { @items.create("", it, "/categories/#{it[:slug]}") }
end

def blog_post_asset_attributes
  blog_post_items.each do |post|
    post_prefix = post.identifier.to_s.sub(/index\.md\z/, "")
    @items.find_all { |asset| asset.identifier.to_s.start_with?(post_prefix) }.each do |item|
    next if item.identifier.to_s.end_with?(".md")

      parent = post

      item[:post_type] = parent[:post_type]
      item[:date] = parent[:date] if parent[:date]
      item[:slug] = parent[:slug]
      item[:category] = parent[:category]
      item[:relative_path] = item.identifier.to_s.split("#{parent[:slug]}/").last
    end
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
