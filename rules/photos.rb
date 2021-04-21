compile "/photos/**/*.jpg", rep: :raw do
  path = item.identifier.without_ext
  file = item.identifier.components.last

  write [path, file].join("/")
end

compile "/photos/**/*.jpg", rep: :html do
  filter :binary_text, content: item[:description]
  layout "/photo.*"

  write item.identifier.without_ext + "/index.html"
end

