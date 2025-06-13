require "json"
require "net/http"
require "uri"

require_relative "config"

module Youtube
  # Simple HTTP client for the YouTube Data API
  class Client
    attr_reader :config

    def initialize(config = nil, api_key: nil)
      @config = config || Youtube::Config.new
      @config.api_key = api_key if api_key && !api_key.empty?
      yield @config if block_given?
    end

    def playlist_items(playlist_id, limit: 50)
      uri = URI("https://www.googleapis.com/youtube/v3/playlistItems")
      params = {
        part: "snippet",
        playlistId: playlist_id,
        maxResults: limit,
        key: config.api_key
      }
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        res = http.request(req)
        JSON.parse(res.body)
      end
    end
  end
end
