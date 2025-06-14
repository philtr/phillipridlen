module Linkding
  class Config
    attr_reader :instance_url
    attr_accessor :token

    def initialize(attrs = {})
      self.instance_url = attrs[:instance_url] || attrs["instance_url"]
      self.token = attrs[:token] || attrs["token"]
      yield self if block_given?
    end

    def instance_url=(url)
      @instance_url = url&.chomp("/")
    end
  end
end
