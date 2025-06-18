# Compilation rules for blog posts and categories.
# Defines preprocess helpers and output paths used for notes and drafts.
#
preprocess do
  blog_post_attributes_from_filename
  blog_post_date_for_drafts
  blog_category_items
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

compile "/feed/all.atom.xml" do
  filter :erb
  write item.identifier
end

compile "/feed/all.json" do
  filter :erb
  write item.identifier.without_ext
end

compile "/feed/notes.atom.xml" do
  filter :erb
  write item.identifier
end

compile "/feed/notes.json" do
  filter :erb
  write item.identifier.without_ext
end
