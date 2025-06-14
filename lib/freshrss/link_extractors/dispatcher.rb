require_relative "daring_fireball"
require_relative "default"

module FreshRSS
  module LinkExtractors
    class Dispatcher
      def initialize(extractors = default_extractors)
        @extractors = extractors
      end

      def call(entry)
        @extractors.each do |extractor|
          result = extractor.call(entry)
          return result if result
        end
        nil
      end

      private

      def default_extractors
        [
          FreshRSS::LinkExtractors::DaringFireball.new,
          FreshRSS::LinkExtractors::Default.new
        ]
      end
    end
  end
end
