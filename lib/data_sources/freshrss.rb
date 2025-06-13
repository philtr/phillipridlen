require "nanoc/data_sources/filesystem"
require "json"
require "net/http"
require "yaml"

module DataSources
  class FreshRSS < Nanoc::DataSources::Filesystem
    identifier :freshrss

    FSTools = Nanoc::DataSources::Filesystem::Tools

    def items
      fetch_and_cache
      super
    end

    def content_dir_name
      config.fetch(:content_dir, "src/links/freshrss")
    end

    private

    def fetch_and_cache
      uri = URI(config.fetch(:url))
      params = { n: limit }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      Array(data["items"]).each do |entry|
        cache_entry(entry)
      end
    rescue StandardError => e
      warn "FreshRSS data source error: #{e.message}"
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
