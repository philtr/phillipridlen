require "base64"
require "nanoc/data_sources/filesystem"
require "yaml"

require_relative "../linkding/client"

module DataSources
  class Linkding < Nanoc::DataSources::Filesystem
    identifier :linkding

    def items
      fetch_and_cache
      super
    end

    def content_dir_name
      config.fetch(:content_dir, "src/links/linkding")
    end

    private

    def fetch_and_cache
      data = client.bookmarks(tags: tags, limit: limit)
      Array(data["results"]).each { |bookmark| cache_bookmark(bookmark) }
    rescue => e
      warn "Linkding data source error: #{e.message}"
    end

    def client
      @client ||= ::Linkding::Client.new do |c|
        c.instance_url = ENV.fetch("LINKDING_URL") { config[:url] }
        c.token = ENV.fetch("LINKDING_TOKEN") { config[:token] }
      end
    end

    def limit
      config.fetch(:limit, 100)
    end

    def tags
      Array(config[:tags])
    end

    def cache_bookmark(bookmark)
      id = sanitize_id(bookmark["id"])
      path = File.join(content_dir_name, "#{id}.md")
      return if File.exist?(path)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, build_document(bookmark))
    end

    def sanitize_id(id)
      Base64.urlsafe_encode64(id.to_s, padding: false)
    end

    def build_document(bookmark)
      attrs = {
        "title" => bookmark["title"],
        "url" => bookmark["url"],
        "published" => bookmark["date_added"].to_s,
        "source" => "Linkding"
      }
      frontmatter = attrs.to_yaml.chomp
      content = bookmark["description"].to_s
      [frontmatter, content].join("\n---\n")
    end
  end
end
