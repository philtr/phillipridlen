require_relative "base"

module LinkExtractors
  class Default < Base
    def call(entry)
      entry.dig("alternate", 0, "href") || entry["originId"]
    end
  end
end
