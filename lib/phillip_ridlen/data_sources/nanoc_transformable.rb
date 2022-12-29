module PhillipRidlen
  module DataSources
    # Adds a `to_nanoc_item` method to an object or class
    module NanocTransformable
      # Include `NanocTransformable::Binary` for binary items, such as images,
      # file attachments, etc.
      module Binary
        def self.included(base) = include(NanocTransformable)
        def binary? = true
        def filename_or_content = filename
      end

      # Include `NanocTransformable::Textual` when the item is primarily
      # textual, such as a database record or external API call.
      module Textual
        def self.included(base) = include(NanocTransformable)
        def binary? = false
        def filename_or_content = content
      end

      def filename = attributes.fetch(:filename)
      def content = attributes.fetch(:content)
      def identifier = Nanoc::Core::Identifier.new(filename)

      def to_nanoc_item(data_source)
        data_source.new_item(
          filename_or_content,
          attributes,
          identifier,
          binary: binary?
        )
      end

      # If `NanocTransformable` was mixed in without `Binary` or `Textual`,
      # raise an error.
      unless method_defined?(:filename_or_content)
        def filename_or_content =
          raise "Must include or extend `NanocTransformable::Binary`" +
                "or `NanocTransformable::Textual`"
      end
    end
  end
end
