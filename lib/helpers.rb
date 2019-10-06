use_helper Nanoc::Helpers::LinkTo
use_helper Nanoc::Helpers::Rendering

NavigationItem = Struct.new(:name, :url, keyword_init: true)

def navigation_items
  @config[:navigation].map do |nav_data|
    NavigationItem.new(nav_data)
  end
end

def posts_grouped_by_category
  result = @items.find_all("/posts/**/*")
    .sort_by { |item| item[:date] - Time.now }
    .reverse
    .group_by { |item| item[:category] }
  result
end
