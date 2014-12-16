require "htmlentities"
require "octokit"

module Jekyll
  # == Use GitHub issues as the comments provider.
  #
  # If an issue does not exist with the title of the post, GitHubIssuesComments will create one with
  # the tag "comments", plus a tag for the post category. The body of the issue will be a link back
  # to the post followed by the post's excerpt. The URL of the issue will be added to the template
  # data as `ghi`.
  class GithubIssuesComments < Jekyll::Generator
    def generate(site)
      return nil if disconnected?
      puts "\nUsing GitHub Issues on #{ repo } for comments..."

      @site = site

      site.posts.each do |post|
        post.data["ghi"] = issue_link(post)
      end
    end

    protected

    # Check for network connection.
    def connected?
      return true if ENV["DO_NOT_CHECK_NETWORK_CONNECTION"]

      connection = begin
        Net::HTTP.start("http://www.github.com") do |http|
          http.read_timeout = 2
          http.head("/")
        end
      rescue
        nil
      end

      !!connection
    end

    def disconnected?
      !connected?
    end

    def github
      @github ||= Octokit::Client.new(access_token: ENV["GITHUB_OAUTH_TOKEN"])
    end

    # Find or create issue for discussion around this post.
    def issue_link(post)
      # Decode the post title (for converting fancy quotes back to their utf-8 versions)
      title = HTMLEntities.new.decode(post.data["title"])

      issues = github.search_issues("#{ title } repo:#{ repo }", labels: "Comments")

      # If an issue is found, return its URL. Otherwise continue on
      if issues.total_count == 0
        body = "**Comments for: #{ @site.config["url"] + post.url }** \n\n#{ post.excerpt }"
        labels = [ "Comments", post.data["category"] ].join(",")

        # Create the issue and return the URL.
        issue = github.create_issue(repo, title, body, labels: labels)
        puts "  --> \033[32m★ \033[0m \033[1mCreated issue ##{ issue.number}\033[0m for #{ title }"
      else
        puts "  --> \033[33m☆ \033[0m \033[1mIssue found, using ##{ issues.items.first.number }\033[0m for #{ title }"
        return issues.items.first.html_url unless issues.total_count == 0
      end

    end

    def repo
      ENV["GITHUB_REPO"]
    end
  end
end
