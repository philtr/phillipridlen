require "nanoc/data_sources/filesystem"

module DataSources
  class Exif < Nanoc::DataSource
    require_relative "./exif/item"
    require_relative "./filesystem_listener"

    include FilesystemListener

    FSTools = Nanoc::DataSources::Filesystem::Tools

    identifier :exif

    def config(key, default = nil) = @config.fetch(key, default)

    def items               = filenames.map { exif_item(_1).to_nanoc_item(self) }
    def exif_item(filename) = Item.new(filename).extend(NanocTransformable::Binary)
    def filenames           = Dir[file_glob].reverse
    def file_glob           = "#{content_dir}/**/*.{#{ext.join(',')}}"
    def content_dir         = FSTools.expand_and_relativize_path(config(:content_dir))
    def ext                 = Array(config(:ext, :jpg))

  end
end
