require "nokogiri"
require_relative "base"

module LinkExtractors
  class DaringFireball < Base
    def call(entry)
      return nil unless entry.dig("origin", "title") == "Daring Fireball"

      html = entry.dig("content", "content") || entry.dig("summary", "content") || ""
      doc = Nokogiri::HTML(html)
      doc.css("a[href*='daringfireball.net/linked/']").map { |a| a["href"] }.first || fallback(entry)
    end

    private

    def fallback(entry)
      entry["originId"] || entry.dig("alternate", 0, "href")
    end
  end
end
