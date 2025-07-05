# Preprocessor helpers for game versioning.
# Extracts version information from filenames and creates an index
# item for the latest version of each game.
GAME_REGEX = %r{\A/games/([^/]+)/(\d{12})\.md\z}

# Returns collection of game version items
def game_items
  @items.find_all(GAME_REGEX)
end

# Sets slug and version attributes on game items
def game_attributes_from_filename
  game_items.each do |item|
    slug, version = item.identifier.to_s.match(GAME_REGEX).captures
    item[:slug] = slug
    item[:version] = version
  end
end

# Marks latest version for each game and creates index item
# pointing at the latest version's content.
def game_latest_items
  game_items.group_by { |i| i[:slug] }.each do |_slug, versions|
    latest = versions.max_by { |i| i[:version] }
    latest[:latest] = true
    @items.create(latest.raw_content, latest.attributes, "/games/#{latest[:slug]}/index.md")
  end
end
