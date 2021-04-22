compile "/photos/**/*.jpg", rep: :original do
  path = item.identifier.without_ext
  file = item.identifier.components.last

  write [path, file].join("/")
end

compile "/photos/**/*.jpg", rep: :medium do
  filter :resize_to_fit, width: 1500

  path = item.identifier.without_ext
  file = "medium-" + item.identifier.components.last

  write [path, file].join("/")
end

compile "/photos/**/*.jpg", rep: :thumbnail do
  filter :resize_to_fill, width: 400, height: 400

  path = item.identifier.without_ext
  file = "thumbnail-" + item.identifier.components.last

  write [path, file].join("/")
end


compile "/photos/**/*.jpg" do
  filter :binary_text, content: item[:description]
  filter :kramdown

  layout "/photo.*"

  write item.identifier.without_ext + "/index.html"
end

