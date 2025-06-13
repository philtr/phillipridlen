require "json"
require "net/http"
require "uri"

module FreshRSS
  # Simple HTTP client for the FreshRSS API.
  # Supports fetching the list of starred items using Google Reader compatible
  # endpoints.
  class Client
    # The configuration used by the client.
    #
    # @return [FreshRSS::Config]
    attr_reader :config

    # Create a new API client.
    #
    # A `FreshRSS::Config` instance can be provided directly, or connection
    # parameters may be given individually.
    #
    # @param config [FreshRSS::Config, nil] optional configuration object
    # @param instance_url [String, nil] base URL of the FreshRSS instance
    # @param username [String, nil] API username
    # @param api_password [String, nil] API password
    def initialize(config = nil, instance_url: nil, username: nil, api_password: nil)
      @config = config || FreshRSS::Config.new

      @config.instance_url = instance_url if instance_url && !instance_url.empty?
      @config.username = username if username && !username.empty?
      @config.api_password = api_password if api_password && !api_password.empty?

      yield @config if block_given?
    end

    # Fetch starred entries for the configured account.
    #
    # @param limit [Integer] maximum number of entries to return
    # @return [Hash] parsed JSON response from the API
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
