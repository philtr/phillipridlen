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

    private def context = ::Nanoc::Core::Context.new(assigns)
    private def options(params) = params.merge(filename:)
    private def proc = assigns[:content] ? -> { assigns[:content] } : nil
  end
end
