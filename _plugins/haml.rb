module Jekyll
  require 'haml'
  require "rubypants-unicode"

  class HamlConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /haml/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      begin
        Tilt.prefer(Tilt::KramdownTemplate)
        engine = Haml::Engine.new(content)
        RubyPants.new(engine.render).to_html
      rescue StandardError => e
          puts "!!! HAML Error: " + e.message
      end
    end
  end
end
