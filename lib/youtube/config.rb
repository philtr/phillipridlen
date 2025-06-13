module Youtube
  # Configuration for Youtube client
  class Config
    attr_accessor :api_key

    def initialize(attrs = {})
      @api_key = attrs[:api_key] || attrs["api_key"]
      yield self if block_given?
    end
  end
end
