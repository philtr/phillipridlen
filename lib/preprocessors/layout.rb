def selected_layout(item)
  return unless (layout = item[:layout])

  "/#{layout}.*"
end
