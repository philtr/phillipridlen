# Stylesheets
ignore '/**/_*.scss'
ignore '/**/_*.scss', rep: :source_map
compile '/**/*.scss' do
  filter :sassc, syntax: :scss

  write ext: '.css'
end
