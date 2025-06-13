require "json"
require "net/http"
require "uri"

module FreshRSS
  class Client
    attr_reader :config

    def initialize(config = nil, instance_url: nil, username: nil, api_password: nil)
      if config
        @config = config
      else
        @config = FreshRSS::Config.new()
      end

      @config.instance_url = instance_url if instance_url && !instance_url.empty?
      @config.username = username if username && !username.empty?
      @config.api_password = api_password if api_password && !api_password.empty?

      yield @config if block_given?
    end

    def starred(limit: 50)
      uri = URI("#{config.instance_url}/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred")
      params = { n: limit, output: 'json' }
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req.basic_auth(config.username, config.api_password)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        res = http.request(req)
        JSON.parse(res.body)
      end
    end
  end
end
