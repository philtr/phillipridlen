require 'sassc'

module Nanoc::Filters
  class SassCFilter < Nanoc::Filter
    identifier :sassc

    def run(content, params = {})
      dir = File.dirname(@item.raw_filename)

      options = params.merge(
        load_paths: [dir],
        filename: @item.raw_filename,
        cache: false,
        style: :compressed
      )

      engine = ::SassC::Engine.new(content, options)
      css = engine.render

      dependencies = engine.dependencies
      if dependencies.any?
        depend_on(
          @items.to_h { |item| [item.raw_filename, item] }
                .fetch_values(*dependencies.map(&:filename))
        )
      end

      css
    end
  end
end
