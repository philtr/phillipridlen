# Rules for error pages such as 404.
# Applies the default layout and HAML processing before writing the HTML file.
#
# 404 Page
compile "/error.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write "/404.html"
end
