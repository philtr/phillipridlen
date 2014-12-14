require "htmlentities"
require "octokit"
require "pry"

module Jekyll
  class GithubIssuesComments < Jekyll::Generator
    def generate(site)
      @site = site

      site.posts.each do |post|
        next unless post.data["category"].downcase == "programming"

        post.data["ghi"] = issue_link(post)
      end
    end

    protected

    def github
      @github ||= Octokit::Client.new(access_token: ENV["GITHUB_OAUTH_TOKEN"])
    end

    def issue_link(post)
      title = HTMLEntities.new.decode(post.data["title"])

      issues = github.search_issues(%("#{title}"), repo: "spatula/phillipridlen", labels: "comments")
      return issues.items.first.html_url unless issues.total_count == 0

      body = "**Comments for: #{ @site.config["url"] + post.url }** \n\n#{ post.excerpt }"

      github.create_issue("spatula/phillipridlen", title, body, labels: "comments").html_url
    end
  end
end
