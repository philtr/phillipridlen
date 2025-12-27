require "base64"
require "nanoc/data_sources/filesystem"
require "yaml"

require_relative "../youtube/client"

module DataSources
  # Data source that fetches videos from YouTube playlists and caches them
  class Youtube < Nanoc::DataSources::Filesystem
    identifier :youtube

    def items
      fetch_and_cache
      super
    end

    def content_dir_name
      config.fetch(:content_dir, "src/links/youtube")
    end

    private

    def fetch_and_cache
      playlists.each do |url|
        playlist_id = extract_playlist_id(url)

        next unless playlist_id

        data = client.playlist_items(playlist_id, limit: limit)
        Array(data["items"]).each { |item| cache_item(item) }
      end
    rescue => e
      warn "YouTube data source error: #{e.message}"
    end

    def playlists
      Array(config[:playlists])
    end

    def extract_playlist_id(url)
      uri = URI.parse(url)
      query = URI.decode_www_form(uri.query.to_s).to_h
      query["list"] || uri.path.split("/").last || url
    rescue URI::InvalidURIError
      url
    end

    def client
      @client ||= ::Youtube::Client.new do |c|
        c.api_key = ENV.fetch("YOUTUBE_API_KEY") { config[:api_key] }
      end
    end

    def limit
      config.fetch(:limit, 50)
    end

    def cache_item(item)
      id = sanitize_id(item["id"])
      path = File.join(content_dir_name, "#{id}.md")
      return if File.exist?(path)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, build_document(item))
    end

    def sanitize_id(id)
      Base64.urlsafe_encode64(id.to_s, padding: false)
    end

    def build_document(item)
      snippet = item["snippet"] || {}
      attrs = {
        "title" => snippet["title"],
        "url" => "https://www.youtube.com/watch?v=#{snippet.dig("resourceId", "videoId")}",
        "published" => (snippet["publishedAt"] || Time.now).to_s,
        "source" => "YouTube"
      }
      frontmatter = attrs.to_yaml.chomp
      content = snippet["description"]
      [frontmatter, content].join("\n---\n")
    end
  end
end
