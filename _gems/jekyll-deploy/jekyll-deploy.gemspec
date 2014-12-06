Gem::Specification.new do |gem|
  gem.name    = "jekyll-deploy"
  gem.version = "0.0.1"
  gem.date    = Date.today.to_s

  gem.summary = "TODO: write this"
  gem.description = "TODO: write this too"

  gem.authors  = ["philtr"]
  gem.email    = "p@rdln.net"

  gem.add_dependency("jekyll")
  gem.add_dependency("s3_website")

  # ensure the gem is built out of versioned files
  gem.files = Dir["{bin,lib,man,test,spec}/**/*"]
end
