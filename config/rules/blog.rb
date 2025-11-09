# Compilation rules for blog posts and categories.
# Defines preprocess helpers and output paths used for notes and drafts.
#
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
  yyyy, mm, dd = @item[:date].strftime("%Y/%m/%d").split("/")
  slug = @item[:slug]

  write "/notes/#{category}/#{yyyy}/#{mm}/#{dd}/#{slug}/index.html"
end

compile "/posts/**/*.{png,jpg,jpeg,gif,webp,avif,svg}" do
  category = item[:category].downcase
  yyyy, mm, dd = item[:date].strftime("%Y/%m/%d").split("/")
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
