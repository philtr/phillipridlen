compile "/photos/**/*.jpg", rep: :original do
  slug = item[:title].parameterize
  date = item[:date].strftime("%Y/%m")
  write "/photos/#{date}/#{slug}/#{slug}.jpg"
end

compile "/photos/**/*.jpg", rep: :medium do
  filter :resize_to_fit, width: 1500
  slug = item[:title].parameterize
  date = item[:date].strftime("%Y/%m")
  write "/photos/#{date}/#{slug}/#{slug}-medium.jpg"
end

compile "/photos/**/*.jpg", rep: :thumbnail do
  filter :resize_to_fill, width: 400, height: 400
  slug = item[:title].parameterize
  date = item[:date].strftime("%Y/%m")
  write "/photos/#{date}/#{slug}/#{slug}-thumbnail.jpg"
end


compile "/photos/**/*.jpg" do
  filter :binary_text, content: item[:description]
  filter :kramdown

  layout "/photo.*"

  slug = item[:title].parameterize
  date = item[:date].strftime("%Y/%m")

  write "/photos/#{date}/#{slug}/index.html"
end
