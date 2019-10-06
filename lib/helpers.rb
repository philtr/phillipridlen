use_helper Nanoc::Helpers::Rendering

NavigationItem = Struct.new(:name, :url, keyword_init: true)

def navigation_items
  @config[:navigation].map { |nav_data| NavigationItem.new(nav_data) }
end
