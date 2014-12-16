Gem::Specification.new do |gem|
  gem.name    = "jekyll-github_issues_comments"
  gem.version = "0.1.0"
  gem.date    = Date.today.to_s

  gem.summary = "Use GitHub Issues for Jekyll comments"
  gem.description = "Synchronize posts with GitHub issues for comments"

  gem.authors  = ["philtr"]
  gem.email    = "p@rdln.net"

  gem.add_dependency("jekyll")
  gem.add_dependency("htmlentities")
  gem.add_dependency("octokit")

  # ensure the gem is built out of versioned files
  gem.files = Dir["{bin,lib,man,test,spec}/**/*"]
end
