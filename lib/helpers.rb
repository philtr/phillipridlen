# Helper methods used in Nanoc templates.
# Provides site configuration accessors and utilities for posts and photos.
#
require "bundler"
require "time"
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

def photos_sorted_by_date(list = photos(), direction: :desc)
  list.sort_by do |item|
    case direction
    when :asc then item.fetch(:date) - Time.now
    when :desc then Time.now - item.fetch(:date)
    end
  end
end

def links
  @items.find_all("/links/**/*")
end

def links_sorted_by_date(items = links, direction: :desc)
  items.sort_by do |item|
    date = Time.parse(item.fetch(:published))
    case direction
    when :asc then date - Time.now
    when :desc then Time.now - date
    end
  end
end

def item_date(item)
  if item[:date]
    item[:date]
  elsif item[:published]
    Time.parse(item[:published])
  else
    Time.now
  end
end

def everything_sorted_by_date(direction: :desc)
  combined = all_posts + photos + links
  sorted = combined.sort_by { |i| item_date(i) }
  (direction == :desc) ? sorted.reverse : sorted
end

# Uses font awesome size XS SVG icons
def link_icon(item)
  case item[:source]&.downcase
  when "freshrss"
    %(<svg xmlns="http://www.w3.org/2000/svg" height="12" width="10.5" viewBox="0 0 448 512"><!--!Font Awesome Free 6.7.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path fill="#ff7300" d="M0 64C0 46.3 14.3 32 32 32c229.8 0 416 186.2 416 416c0 17.7-14.3 32-32 32s-32-14.3-32-32C384 253.6 226.4 96 32 96C14.3 96 0 81.7 0 64zM0 416a64 64 0 1 1 128 0A64 64 0 1 1 0 416zM32 160c159.1 0 288 128.9 288 288c0 17.7-14.3 32-32 32s-32-14.3-32-32c0-123.7-100.3-224-224-224c-17.7 0-32-14.3-32-32s14.3-32 32-32z"/></svg>)
  when "linkding"
    %(<svg xmlns="http://www.w3.org/2000/svg" height="12" width="9" viewBox="0 0 384 512"><!--!Font Awesome Free 6.7.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path fill="#5755d8" d="M32 32C32 14.3 46.3 0 64 0L320 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-29.5 0 11.4 148.2c36.7 19.9 65.7 53.2 79.5 94.7l1 3c3.3 9.8 1.6 20.5-4.4 28.8s-15.7 13.3-26 13.3L32 352c-10.3 0-19.9-4.9-26-13.3s-7.7-19.1-4.4-28.8l1-3c13.8-41.5 42.8-74.8 79.5-94.7L93.5 64 64 64C46.3 64 32 49.7 32 32zM160 384l64 0 0 96c0 17.7-14.3 32-32 32s-32-14.3-32-32l0-96z"/></svg>)
  when "youtube"
    %(<svg xmlns="http://www.w3.org/2000/svg" height="12" width="13.5" viewBox="0 0 576 512"><!--!Font Awesome Free 6.7.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path fill="#ff0000" d="M549.7 124.1c-6.3-23.7-24.8-42.3-48.3-48.6C458.8 64 288 64 288 64S117.2 64 74.6 75.5c-23.5 6.3-42 24.9-48.3 48.6-11.4 42.9-11.4 132.3-11.4 132.3s0 89.4 11.4 132.3c6.3 23.7 24.8 41.5 48.3 47.8C117.2 448 288 448 288 448s170.8 0 213.4-11.5c23.5-6.3 42-24.2 48.3-47.8 11.4-42.9 11.4-132.3 11.4-132.3s0-89.4-11.4-132.3zm-317.5 213.5V175.2l142.7 81.2-142.7 81.2z"/></svg>)
  else
    %(<svg xmlns="http://www.w3.org/2000/svg" height="12" width="15" viewBox="0 0 640 512"><!--!Font Awesome Free 6.7.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path fill="#bfbfbf" d="M579.8 267.7c56.5-56.5 56.5-148 0-204.5c-50-50-128.8-56.5-186.3-15.4l-1.6 1.1c-14.4 10.3-17.7 30.3-7.4 44.6s30.3 17.7 44.6 7.4l1.6-1.1c32.1-22.9 76-19.3 103.8 8.6c31.5 31.5 31.5 82.5 0 114L422.3 334.8c-31.5 31.5-82.5 31.5-114 0c-27.9-27.9-31.5-71.8-8.6-103.8l1.1-1.6c10.3-14.4 6.9-34.4-7.4-44.6s-34.4-6.9-44.6 7.4l-1.1 1.6C206.5 251.2 213 330 263 380c56.5 56.5 148 56.5 204.5 0L579.8 267.7zM60.2 244.3c-56.5 56.5-56.5 148 0 204.5c50 50 128.8 56.5 186.3 15.4l1.6-1.1c14.4-10.3 17.7-30.3 7.4-44.6s-30.3-17.7-44.6-7.4l-1.6 1.1c-32.1 22.9-76 19.3-103.8-8.6C74 372 74 321 105.5 289.5L217.7 177.2c31.5-31.5 82.5-31.5 114 0c27.9 27.9 31.5 71.8 8.6 103.9l-1.1 1.6c-10.3 14.4-6.9 34.4 7.4 44.6s34.4 6.9 44.6-7.4l1.1-1.6C433.5 260.8 427 182 377 132c-56.5-56.5-148-56.5-204.5 0L60.2 244.3z"/></svg>)
  end
end

def git_tag = @git_tag ||= `git describe --tags --abbrev=0`.chomp

def git_rev = @git_rev ||= `git rev-parse --short HEAD`.chomp

def github = "https://github.com/philtr/phillipridlen"

def site_version
  %(<span class="revision">#{link_to git_tag, @items["/build-info.*"]}</span>)
end
