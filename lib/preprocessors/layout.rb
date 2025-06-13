# Preprocessor helper that picks a layout based on item attributes.
# Returns a glob used by the rules file when compiling an item.
#
def selected_layout(item)
  if (layout = item[:layout])
    "/#{layout}.*"
  end
end
