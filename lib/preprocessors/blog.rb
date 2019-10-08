def preprocess_blog
  begin # blog post attributes from filename
    post_regex = %r{\A/posts/(link|note)s/(\d+)-(\d+)-(\d+)-(.+).md\z}
    @items.find_all(post_regex).each do |item|
      post_type, year, month, day, slug = item.identifier.to_s.match(post_regex).captures
      item[:post_type] = post_type
      item[:date] = Time.new(year, month, day)
      item[:slug] = slug
    end
  end

  begin # assign date for drafts
    @items.find_all("/drafts/**/*").each do |item|
      item[:date] = Time.now
    end
  end if @config[:drafts]
end
