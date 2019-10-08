# Blog Posts
compile "/posts/**/*.md" do
  filter :erb
  filter :kramdown
  filter :colorize_syntax, default_colorizer: :rouge

  layout "/post.*"
  filter :typogruby

  category      = @item[:category].downcase
  yyyy, mm, dd  = [@item[:date].year, @item[:date].month, @item[:date].day]
  slug          = @item[:slug]

  write "/#{category}/#{yyyy}/#{mm}/#{dd}/#{slug}/index.html"
end

if @config[:drafts]
  compile "/drafts/**/*" do
    filter :erb
    filter :kramdown
    filter :colorize_syntax, default_colorizer: :rouge

    layout "/post.*"
    filter :typogruby

    write item.identifier.without_ext + "/index.html"
  end
else
  ignore "/drafts/**/*"
end

compile "/atom.xml" do
  filter :erb
  write item.identifier
end
