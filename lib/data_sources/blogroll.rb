require "nanoc"
require "nanoc/data_sources/filesystem"
require "yaml"

module DataSources
  class Blogroll < Nanoc::DataSource
    require_relative "filesystem_listener"

    include FilesystemListener

    REQUIRED_KEYS = %w[note rss_url title url].freeze

    identifier :blogroll

    def items
      visible_entries.each_with_index.map { |entry, position| build_item(entry, position) }
    end

    private

    def build_item(entry, position)
      title = entry.fetch("title")
      slug = "#{position}-#{slugify(title)}"

      new_item(
        entry.fetch("note"),
        {
          title: title,
          url: entry.fetch("url"),
          rss_url: entry.fetch("rss_url"),
          favicon_url: entry["favicon_url"],
          position: position
        },
        Nanoc::Core::Identifier.new("/#{slug}.md"),
        binary: false
      )
    end

    def load_entries
      data = YAML.safe_load_file(data_file) || []
      return data if data.is_a?(Array)

      raise "Blogroll data source expects a top-level array in #{data_file}"
    end

    def visible_entries
      load_entries.each_with_index.filter_map do |entry, index|
        next unless visible_entry?(entry)

        validate_entry!(entry, index)
      end
    end

    def validate_entry!(entry, index)
      unless entry.is_a?(Hash)
        raise "Blogroll entry #{index} in #{data_file} must be a mapping"
      end

      missing = REQUIRED_KEYS.reject { |key| entry[key].to_s.strip != "" }
      return entry if missing.empty?

      raise "Blogroll entry #{index} in #{data_file} is missing required keys: #{missing.join(", ")}"
    end

    def visible_entry?(entry)
      entry["display"] != false
    end

    def slugify(value)
      slug = value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
      slug.empty? ? "entry" : slug
    end

    def data_file
      @data_file ||= File.join(content_dir, @config.fetch(:file, "blogroll.yml"))
    end

    def content_dir
      @content_dir ||= Nanoc::DataSources::Filesystem::Tools
        .expand_and_relativize_path(@config.fetch(:content_dir, "src/data"))
    end
  end
end
