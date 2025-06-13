require "base64"
require "nanoc/data_sources/filesystem"
require "yaml"

require_relative "../freshrss/client"

module DataSources
  # Data source that fetches starred items from a FreshRSS instance.
  # Fetched entries are cached as Markdown files under the configured directory.
  #
  class FreshRSS < Nanoc::DataSources::Filesystem
    identifier :freshrss

    def items
      fetch_and_cache
      super
    end

    def content_dir_name
      config.fetch(:content_dir, "src/links/freshrss")
    end

    private

    def fetch_and_cache
      data = client.starred(limit: limit)
      Array(data["items"]).each { |entry| cache_entry(entry) }
    rescue => e
      warn "FreshRSS data source error: #{e.message}"
    end

    def client
      @client ||= ::FreshRSS::Client.new do |c|
        c.instance_url = ENV.fetch("FRESHRSS_INSTANCE_URL") { config[:url] }
        c.username = ENV.fetch("FRESHRSS_USERNAME") { config[:username] }
        c.api_password = ENV.fetch("FRESHRSS_API_PASSWORD") { config[:api_password] }
      end
    end

    def limit
      config.fetch(:limit, 50)
    end

    def cache_entry(entry)
      id = sanitize_id(entry["id"].to_s)
      path = File.join(content_dir_name, "#{id}.md")
      return if File.exist?(path)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, build_document(entry))
    end

    def sanitize_id(id)
      Base64.urlsafe_encode64(id, padding: false)
    end

    def build_document(entry)
      attrs = {
        "title" => entry["title"],
        "url" => entry.dig("alternate", 0, "href"),
        "published" => Time.at(entry["published"]).to_s,
        "source" => "FreshRSS"
      }
      frontmatter = attrs.to_yaml.chomp
      content = entry.dig("summary", "content")
      [frontmatter, content].join("\n---\n")
    end
  end
end
