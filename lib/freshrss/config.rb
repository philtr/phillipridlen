# frozen_string_literal: true

module FreshRSS
  # Configuration container for the FreshRSS client.
  # Stores connection details such as instance URL and credentials.
  class Config
    # URL of the FreshRSS instance.
    attr_reader :instance_url
    # Username used for API requests.
    attr_reader :username
    # API password for the user.
    attr_reader :api_password

    # Set the username.
    attr_writer :username
    # Set the API password.
    attr_writer :api_password

    # Initialize a new configuration object.
    #
    # @param attrs [Hash] optional attributes
    # @yieldparam config [Config] yields itself for configuration
    def initialize(attrs = {})
      self.instance_url = attrs[:instance_url] || attrs["instance_url"]
      self.username = attrs[:username] || attrs["username"]
      self.api_password = attrs[:api_password] || attrs["api_password"]

      yield self if block_given?
    end

    # Set the URL of the FreshRSS instance.
    # Trailing slashes are removed.
    #
    # @param instance_url [String]
    def instance_url=(instance_url)
      @instance_url = instance_url&.chomp("/")
    end
  end
end
