# Main Index Page
compile "/index.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write "/index.html"
end
