# Stylesheets
ignore "/**/_*.scss"
ignore "/**/_*.scss", rep: :source_map

compile "/**/*.scss" do
  filter :dart_sass, syntax: :scss
  write ext: ".css"
end
