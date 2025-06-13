require "json"
require "net/http"
require "uri"

module FreshRSS
  class Client
    def initialize(base_url:, username:, api_password:)
      @base_url = base_url.chomp('/')
      @username = username
      @api_password = api_password
    end

    def starred(limit: 50)
      uri = URI("#{@base_url}/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred")
      params = { n: limit, output: 'json' }
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req.basic_auth(@username, @api_password)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        res = http.request(req)
        JSON.parse(res.body)
      end
    end
  end
end
