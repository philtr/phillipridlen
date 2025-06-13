# Helper methods used in Nanoc templates.
# Provides site configuration accessors and utilities for posts and photos.
#
require "bundler"
Bundler.require

use_helper Nanoc::Helpers::LinkTo
use_helper Nanoc::Helpers::Rendering

SiteConfig = Struct.new(
  :author,
  :base_url,
  :email,
  :tz,
  keyword_init: true
)

def site_config
  site = SiteConfig.new(@config[:site])

  SiteConfig.new(
    base_url: ENV["URL"] || ENV["BASE_URL"] || site.base_url,
    email: ENV["EMAIL"] || site.email,
    author: ENV["AUTHOR"] || site.author
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
  grouped_posts = posts_sorted_by_date(posts, direction: sort)
    .group_by { |item| item[:category] }

  priority = %w[Life Programming Christianity]
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

def git_tag = @git_tag ||= `git describe --tags --abbrev=0`.chomp

def git_rev = @git_rev ||= `git rev-parse --short HEAD`.chomp

def github = "https://github.com/philtr/phillipridlen"

def site_version
  %(<span class="revision">#{link_to git_tag, @items["/build-info.*"]}</span>)
end
