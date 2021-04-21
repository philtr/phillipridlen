require "exiftool_vendored"

class ExifDataSource < Nanoc::DataSource
  identifier :exif

  def items
    photo_filenames.map do |file|
      item = ExifItem.new(exiftool.result_for(file))

      new_item(
        item.filename,
        item.metadata,
        identifier_for(file, ext: :jpg),
        binary: true
      )
    end
  end

  class ExifItem
    def initialize(exif)
      @exif = exif
    end

    def filename
      @exif[:source_file]
    end

    def metadata
      {
        title: @exif[:image_description],
        description: @exif[:user_comment],
        camera: [@exif[:make], @exif[:model]].join(" "),
        lens: replace_f_stop(@exif[:lens_info]),
        f_stop: "𝑓/#{@exif[:f_number]}",
        exposure: "#{@exif[:exposure_time]}s",
        iso: @exif[:iso],
        exif: @exif.to_hash,
      }
    end

    private

    def replace_f_stop(str)
      str.gsub("f/", "𝑓/")
    end
  end

  private

  def content_dir
    @config.fetch(:content_dir, "photos").sub(%r{\A/},"")
  end

  def photo_filenames
    @photo_filenames ||= Dir["./#{content_dir}/**/*.jpg"]
  end

  def exiftool
    @exiftool ||= Exiftool.new(photo_filenames)
  end

  def identifier_for(file, ext:)
    Nanoc::Identifier.new(Nanoc::Identifier.new(file.sub(%r{\A\.},"")).without_ext + ".#{ext}")
  end
end
