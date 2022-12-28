POST_REGEX = %r{\A/posts/(link|note)s/(\d+)-(\d+)-(\d+)-(.+).md\z}

def blog_post_items
  @items.find_all(POST_REGEX)
end

def blog_post_attributes_from_filename
  blog_post_items.each do |item|
    post_type, year, month, day, slug = item.identifier.to_s.match(POST_REGEX).captures
    item[:post_type] = post_type
    item[:date] = Time.new(year, month, day)
    item[:slug] = slug
  end
end

def blog_category_items
  blog_post_items
    .map { _1[:category].downcase }.uniq
    .map { {name: _1.titleize, slug: _1.parameterize } }
    .map { @items.create("", _1, "/categories/#{_1[:slug]}") } 
end

def blog_post_date_for_drafts
  if @config[:drafts]
    @items.find_all("/drafts/**/*").each do |item|
      item[:date] = Time.now
    end
  end
end
