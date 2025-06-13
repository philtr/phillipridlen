# Rules for Haml templates.
# Haml content is filtered and written using the default layout.
#
# Haml
compile "/**/*.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write item.identifier.without_ext + "/index.html"
end
