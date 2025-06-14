require "json"
require "net/http"
require "uri"

require_relative "config"

module Linkding
  class Client
    attr_reader :config

    def initialize(config = nil, instance_url: nil, token: nil)
      @config = config || Linkding::Config.new
      @config.instance_url = instance_url if instance_url && !instance_url.empty?
      @config.token = token if token && !token.empty?
      yield @config if block_given?
    end

    def bookmarks(tags: [], limit: 100)
      uri = URI("#{config.instance_url}/api/bookmarks/")
      params = {limit: limit}
      unless tags.empty?
        params[:q] = tags.map { |t| "##{t}" }.join(" ")
      end
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Token #{config.token}"

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        res = http.request(req)
        JSON.parse(res.body)
      end
    end
  end
end
