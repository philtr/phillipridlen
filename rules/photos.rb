compile "/photos/**/*.jpg", rep: :original do
  slug = @item[:title].parameterize
  write "/photos/#{slug}/#{slug}.jpg"
end

compile "/photos/**/*.jpg", rep: :medium do
  filter :resize_to_fit, width: 1500
  slug = @item[:title].parameterize

  write "/photos/#{slug}/#{slug}-medium.jpg"
end

compile "/photos/**/*.jpg", rep: :thumbnail do
  filter :resize_to_fill, width: 400, height: 400
  slug = @item[:title].parameterize

  write "/photos/#{slug}/#{slug}-thumbnail.jpg"
end


compile "/photos/**/*.jpg" do
  filter :binary_text, content: item[:description]
  filter :kramdown

  layout "/photo.*"

  write "/photos/#{@item[:title].parameterize}/index.html"
end

