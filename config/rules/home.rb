# Rules for the site home page.
# Compiles the index template with Haml and typogruby filters.
#
# Main Index Page
compile "/index.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write "/index.html"
end
