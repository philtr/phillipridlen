# Compilation rules for blog posts and categories.
# Defines preprocess helpers and output paths used for notes and drafts.
#
require "time"

preprocess do
  blog_post_attributes_from_filename
  blog_post_date_for_drafts
  blog_category_items
  blog_post_asset_attributes
end

compile "/posts/**/*.md" do
  filter :erb
  filter :kramdown
  filter :colorize_syntax, default_colorizer: :rouge

  layout "/post.*"
  filter :typogruby

  category = @item[:category].downcase
  date_value = @item[:date]
  begin
    date_value = date_value.to_time if date_value.respond_to?(:to_time) && !date_value.is_a?(Time)
    date_value = Time.parse(date_value.to_s) unless date_value.is_a?(Time)
  rescue ArgumentError, TypeError
    date_value = Time.at(0)
  end
  yyyy, mm, dd = date_value.strftime("%Y/%m/%d").split("/")
  slug = @item[:slug]

  write "/notes/#{category}/#{yyyy}/#{mm}/#{dd}/#{slug}/index.html"
end

compile "/posts/**/*.{png,jpg,jpeg,gif,webp,avif,svg}" do
  category = item[:category].downcase
  date_value = item[:date]
  begin
    date_value = date_value.to_time if date_value.respond_to?(:to_time) && !date_value.is_a?(Time)
    date_value = Time.parse(date_value.to_s) unless date_value.is_a?(Time)
  rescue ArgumentError, TypeError
    date_value = Time.at(0)
  end
  yyyy, mm, dd = date_value.strftime("%Y/%m/%d").split("/")
  slug = item[:slug]
  img_path = item.identifier.to_s.split("#{slug}/").last

  write "/notes/#{category.downcase}/#{yyyy}/#{mm}/#{dd}/#{slug}/#{img_path}"
end

compile "/categories/*" do
  layout "/category.html"
  filter :typogruby

  slug = @item[:slug]

  write "/notes/#{slug}/index.html"
end

if @config[:drafts]
  compile "/drafts/**/*" do
    filter :erb
    filter :kramdown
    filter :colorize_syntax, default_colorizer: :rouge

    layout "/post.*"
    filter :typogruby

    write "/notes/#{item.identifier.without_ext}/index.html"
  end
else
  ignore "/drafts/**/*"
end

compile "/atom.xml" do
  filter :erb
  write item.identifier
end
