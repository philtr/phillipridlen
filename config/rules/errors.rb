# 404 Page
compile "/error.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write "/404.html"
end
