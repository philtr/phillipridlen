# KJHS 2016
compile "/resources/kjhs-2016.haml" do
  filter :haml

  layout "/default.*"
  filter :typogruby

  write "/resources/kjhs/2016/index.html"
end
