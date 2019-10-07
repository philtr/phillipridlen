use_helper Nanoc::Helpers::LinkTo
use_helper Nanoc::Helpers::Rendering

NavigationItem = Struct.new(:name, :url, keyword_init: true)
SiteConfig = Class.new(OpenStruct)

def site_config
  site = SiteConfig.new(@config[:site])

  SiteConfig.new(
    base_url: ENV["URL"] || ENV["BASE_URL"] || site.base_url,
    email: ENV["EMAIL"] || site.email,
    author: ENV["AUTHOR"] || site.author,
  )
end

def navigation_items
  @config[:navigation].map do |nav_data|
    NavigationItem.new(nav_data)
  end
end

def posts
  @items.find_all("/posts/**/*")
end

def posts_sorted_by_date(direction: :desc)
  posts.sort_by do |item|
    case direction
    when :asc then item.fetch(:date) - Time.now
    when :desc then Time.now - item.fetch(:date)
    end
  end
end

def posts_grouped_by_category(sort: :desc)
  posts_sorted_by_date(direction: sort)
    .group_by { |item| item[:category] }
end
