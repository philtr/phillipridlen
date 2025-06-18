# Rules for links feed

compile "/feed/links.atom.xml" do
  filter :erb
  write item.identifier
end

compile "/feed/links.json" do
  filter :erb
  write item.identifier.without_ext
end
