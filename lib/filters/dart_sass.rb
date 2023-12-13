require "sass-embedded"

module Nanoc::Filters
  class DartSass < Nanoc::Filter
    identifier :dart_sass

    def run(content, params = {})
      dir = File.dirname(@item.raw_filename)
      options = params.merge(load_paths: [dir])
      Sass.compile_string(content, **options).css
    end
  end
end
