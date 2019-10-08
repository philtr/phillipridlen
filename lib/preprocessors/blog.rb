def blog_post_attributes_from_filename
  post_regex = %r{\A/posts/(link|note)s/(\d+)-(\d+)-(\d+)-(.+).md\z}
  @items.find_all(post_regex).each do |item|
    post_type, year, month, day, slug = item.identifier.to_s.match(post_regex).captures
    item[:post_type] = post_type
    item[:date] = Time.new(year, month, day)
    item[:slug] = slug
  end
end

def blog_post_date_for_drafts
  if @config[:drafts]
    @items.find_all("/drafts/**/*").each do |item|
      item[:date] = Time.now
    end
  end
end
