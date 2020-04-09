require "nokogiri"

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
  @config.fetch(:navigation, []).map do |nav_data|
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

def church_av_resources
  uri = URI("https://docs.google.com/document/d/e/2PACX-1vQy9mIg73kxkN2tG9u1N4svmeuJ2Q2Kn4RhhrhaEWEMbX1wBjsFCAL1oEKDWAxlsgccrrwQa8dozrzE/pub")
  document = Nokogiri::HTML(Net::HTTP.get(uri))
  document.encoding = "UTF-8"
  document.xpath('.//@style').remove
  document.css('a').each do |link|
    href = link.attributes["href"].value
    if href =~ /google.com/
      href = href.gsub(%r{https://www.google.com/url\?q=}, '')
      href = href.gsub(%r{&sa=.+&ust=\d+}, '')
      href = CGI.unescape(href)
    end

    link.attributes["href"].value = href
  end
  document.css("#contents").to_html.encode("UTF-8", invalid: :replace, undef: :replace)
end
