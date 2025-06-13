require "exiftool_vendored"

require_relative "../nanoc_transformable"

module DataSources
  # Represents a single image with EXIF metadata.
  # Provides helper methods for building a Nanoc item from an image file.
  #
  class Exif::Item
    # Provides `to_nanoc_item` for binary items
    include NanocTransformable::Binary

    attr_reader :attributes

    # Format for parsing EXIF date strings
    EXIF_DATE_FORMAT = "%Y:%m:%d %H:%M:%S"
    # Unit/postfix for "seconds" of exposure
    SECONDS = "𝑠"
    # Unit/prefix for F-stop focal length
    F_STOP = "𝑓/"

    def initialize(filename)
      @exif = Exiftool.new(filename).to_hash.freeze
      @attributes = build_attributes
    end

    private

    def build_attributes
      {
        # Image Description
        title: exif(:image_description),
        # Description or caption
        description: exif(:user_comment),
        # DateTime object parsed from the EXIF string
        date: parse_exif_date(exif(:date_time_original)),
        # Source filename
        filename: exif(:source_file),
        # Camera make and model
        camera: [exif(:make), exif(:model)].join(" "),
        # Lens information, with fancy "𝑓"
        lens: replace_f_stop(exif(:lens_info)),
        # F-stop, with fancy "𝑓"
        f_stop: "#{F_STOP}#{exif(:f_number)}",
        # Exposure time in seconds, with fancy "𝑠"
        exposure: "#{exif(:exposure_time)}#{SECONDS}",
        # ISO number
        iso: exif(:iso)
      }.transform_values(&:freeze).freeze
    end

    def exif(key)
      @exif.fetch(key)
    end

    def replace_f_stop(str)
      str.gsub("f/", F_STOP)
    end

    def parse_exif_date(exif_date_str)
      Time.strptime(exif_date_str, EXIF_DATE_FORMAT)
    end
  end
end
