# Rules for compiling Markdown sources.
# Content is rendered through ERB and Kramdown before layout and typogruby are applied.
#
route "/sites/*.md" do
  nil
end

compile "/sites/*.md" do
  filter :erb
  filter :kramdown, **config[:kramdown_opts]
  filter :typogruby
end

# Markdown
compile "/**/*.md" do
  next if item[:site_entry]

  filter :erb
  filter :kramdown, **config[:kramdown_opts]
  filter :colorize_syntax, default_colorizer: :rouge

  layout selected_layout(@item) || "/default.*"

  filter :typogruby

  write item.identifier.without_ext + "/index.html"
end
