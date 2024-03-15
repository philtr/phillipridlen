# Haml
compile "/**/*.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write "#{item.identifier.without_ext}/index.html"
end
