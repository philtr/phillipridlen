require "nanoc/data_sources/filesystem"
require "yaml"
require_relative "../freshrss/client"

module DataSources
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
    rescue StandardError => e
      warn "FreshRSS data source error: #{e.message}"
    end

    def client
      @client ||= ::FreshRSS::Client.new(
        base_url: config.fetch(:url),
        username: config.fetch(:username),
        api_password: config.fetch(:api_password)
      )
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
      id.gsub(/[^0-9A-Za-z_-]/, "_")
    end

    def build_document(entry)
      attrs = {
        "title" => entry["title"],
        "url" => entry.dig("alternate", 0, "href"),
        "published" => Time.at(entry["published"]).to_s,
        "source" => "FreshRSS",
      }
      frontmatter = attrs.to_yaml.chomp
      content = entry["content"] || entry["summary"] || ""
      "---\n#{frontmatter}\n---\n#{content}\n"
    end
  end
end
