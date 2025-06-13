module FreshRSS
  class Config
    attr_reader :instance_url, :username, :api_password
    attr_writer :username, :api_password

    def initialize(attrs = {})
      self.instance_url = attrs[:instance_url] || attrs["instance_url"]
      self.username = attrs[:username] || attrs["username"]
      self.api_password = attrs[:api_password] || attrs["api_password"]

      yield self if block_given?
    end

    def instance_url=(instance_url)
      @instance_url = instance_url&.chomp("/")
    end
  end
end
