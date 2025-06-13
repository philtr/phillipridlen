# Simple HTTP client for the FreshRSS API.
# Supports fetching the list of starred items using Google Reader compatible endpoints.
#
require "json"
require "net/http"
require "uri"

module FreshRSS
  class Client
    attr_reader :config

    def initialize(config = nil, instance_url: nil, username: nil, api_password: nil)
      @config = config || FreshRSS::Config.new

      @config.instance_url = instance_url if instance_url && !instance_url.empty?
      @config.username = username if username && !username.empty?
      @config.api_password = api_password if api_password && !api_password.empty?

      yield @config if block_given?
    end

    def starred(limit: 50)
      uri = URI("#{config.instance_url}/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred")
      params = {n: limit, output: "json"}
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "GoogleLogin auth=#{token}"

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        res = http.request(req)
        JSON.parse(res.body)
      end
    end

    private

    def token
      return @token if defined?(@token)

      uri = URI("#{config.instance_url}/api/greader.php/accounts/ClientLogin")
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(Email: config.username, Passwd: config.api_password)

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req)
      end

      @token = res.body[/^Auth=(.+)$/, 1]
    end
  end
end
