compile "/_redirects.erb" do
  filter :erb, trim_mode: "-"
  write "/_redirects"
end
