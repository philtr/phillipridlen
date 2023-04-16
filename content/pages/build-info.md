---
title: Build Information
---

# Build Information

## Version `<%= git_tag %>`, Revision `<%= git_rev %>`

- <%= link_to "Version #{git_tag} Release Notes", "#{github}/releases/tag/#{git_tag}" %> on GitHub
- <%= link_to "Changes since #{git_tag} release", "#{github}/compare/#{git_tag}...#{git_rev}" %> on GitHub
- <%= link_to "Browse source files", "#{github}/tree/#{git_rev}" %> on GitHub
<% if ENV["BUILD_ID"] %>- **Netlify `BUILD_ID`:** `<%= ENV["BUILD_ID"] %>`<% end %>
<% if ENV["DEPLOY_ID"] %>- **Netlify `DEPLOY_ID`:** `<%= ENV["DEPLOY_ID"] %>`<% end %>
