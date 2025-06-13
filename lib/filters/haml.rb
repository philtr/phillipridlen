# Custom Haml filter used by Nanoc.
# Wraps the standard Haml template rendering with Nanoc context helpers.
#
require "haml"

module NanocFilters
  class Haml < Nanoc::Filter
    identifier :haml

    requires "haml"

    def run(content, params = {})
      ::Haml::Template
        .new(options(params)) { content }
        .render(context, assigns, &proc)
    end

    private

    def context = ::Nanoc::Core::Context.new(assigns)

    def options(params) = params.merge(filename: filename)

    def proc = assigns[:content] ? -> { assigns[:content] } : nil
  end
end
