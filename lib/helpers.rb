require "bundler"
Bundler.require

use_helper Nanoc::Helpers::LinkTo
use_helper Nanoc::Helpers::Rendering

SiteConfig = Class.new(OpenStruct)

def site_config
  site = SiteConfig.new(@config[:site])

  SiteConfig.new(
    base_url: ENV["URL"] || ENV["BASE_URL"] || site.base_url,
    email: ENV["EMAIL"] || site.email,
    author: ENV["AUTHOR"] || site.author,
  )
end

def body_classes
  @body_classes.to_a + @item[:body_classes].to_a
end

def page_image
  if @item.attributes[:image]
    "/images/#{@item.attributes[:image]}"
  else
    @item.reps[:medium]&.path
  end
end

def all_posts
  @items.find_all("/posts/**/*")
end

def posts_sorted_by_date(posts = all_posts, direction: :desc)
  posts.sort_by do |item|
    case direction
    when :asc then item.fetch(:date) - Time.now
    when :desc then Time.now - item.fetch(:date)
    end
  end
end

def posts_grouped_by_category(posts = all_posts, sort: :desc)
  grouped_posts = posts_sorted_by_date(direction: sort)
    .group_by { |item| item[:category] }

  priority = ["Life", "Programming", "Christianity"]
  rest = grouped_posts.keys - priority

  grouped_posts.slice(*priority, *rest)
end

def link_to_category(category)
  link_to category, @items["/categories/#{category.downcase}"]
end

def photos
  @items.find_all("/photos/**/*")
end

def photos_grouped_by_year
  photos.group_by { |item| item[:date].year }
end

def google_doc_content(uri)
  response = Net::HTTP.get(URI(uri))
  document = Nokogiri::HTML(response)

  document.encoding = "UTF-8"

  # Remove Google proxy from links
  document.css("a").each do |link|
    href = link.attributes["href"].value
    if href =~ /google.com/
      href = href.gsub(%r{https://www.google.com/url\?q=}, "")
      href = href.gsub(%r{&sa=.+&ust=\d+}, "")
      href = CGI.unescape(href)
    end
    link.attributes["href"].value = href
  end

  document.xpath(".//style").remove

  document_html = document.css("#contents").to_html
    .encode("UTF-8", invalid: :replace, undef: :replace)

  %{<div class="google-doc">#{document_html}</div>}
end

def site_version
  @version ||= `git describe --tags --abbrev=0`.chomp
  @revision ||= `git rev-parse --short HEAD`.chomp

  version_link = link_to @version, "https://github.com/philtr/phillipridlen/releases/tag/#@version"
  version_link = %(<span class="revision">#{version_link}</span>)

  revision_link = link_to @revision, "https://github.com/philtr/phillipridlen/tree/#@revision"
  revision_link = %( (<span class="revision">#{revision_link}</span>))

  if @version == `git describe --tags`.chomp
    version_link
  else
    version_link + revision_link
  end
end
