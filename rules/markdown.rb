# Markdown
compile "/**/*.md" do
  filter :erb
  filter :kramdown
  filter :colorize_syntax, default_colorizer: :rouge

  layout selected_layout(@item) || "/default.*"

  filter :typogruby

  write "#{item.identifier.without_ext}/index.html"
end
