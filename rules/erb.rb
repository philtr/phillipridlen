# ERB
compile "/**/*.erb" do
  filter :erb
  layout "/default.*"
  write "#{item.identifier.without_ext}/index.html"
end
