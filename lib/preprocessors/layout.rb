def selected_layout(item)
  if (layout = item[:layout])
    "/#{layout}.*"
  end
end
