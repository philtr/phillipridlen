# Rules for compiling ERB templates.
# Each template is rendered and written with the default layout.
#
# ERB
compile "/**/*.erb" do
  filter :erb
  layout "/default.*"
  write item.identifier.without_ext + "/index.html"
end
