# Compilation rules for game pages with immutable versions.
# Creates latest index page for each game and versioned permalinks.

preprocess do
  game_attributes_from_filename
  game_latest_items
end

compile "/games/**/*.md" do
  filter :erb
  filter :kramdown
  filter :colorize_syntax, default_colorizer: :rouge

  layout selected_layout(@item) || "/default.*"
  filter :typogruby

  slug = @item[:slug]
  version = @item[:version]

  if @item.identifier.end_with?("index.md")
    write "/games/#{slug}/index.html"
  else
    write "/games/#{slug}/#{version}/index.html"
  end
end
