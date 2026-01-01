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

    def initialize(filename)
      @exif = Exiftool.new(filename).to_hash.freeze
      @attributes = build_attributes
    end

    private

    def build_attributes
      {
        # IPTC Headline (photo title)
        title: exif_value(:headline, :image_description),
        # IPTC Caption-Abstract (photo journal)
        description: exif_value(:"caption-abstract", :user_comment),
        # DateTime object parsed from the EXIF string
        date: exif_date(exif(:date_time_original)),
        # Source filename
        filename: exif(:source_file),
        # Camera make and model
        camera: [exif(:make), exif(:model)].join(" "),
        # Lens information, with fancy "𝑓"
        lens: replace_f_stop(exif(:lens_info)),
        # F-stop, with fancy "𝑓"
        f_stop: "#{f_stop_prefix}#{exif(:f_number)}",
        # Exposure time in seconds, with fancy "𝑠"
        exposure: "#{exif(:exposure_time)}#{seconds_unit}",
        # ISO number
        iso: exif(:iso)
      }.transform_values(&:freeze).freeze
    end

    def exif(key) = @exif.fetch(key)

    def exif_value(*keys)
      keys.each do |key|
        return @exif[key] if @exif.key?(key)
      end
      nil
    end

    def replace_f_stop(str) = str.gsub("f/", f_stop_prefix)

    def exif_date(str) = Time.strptime(str, "%Y:%m:%d %H:%M:%S")

    private

    def seconds_unit = "𝑠"

    def f_stop_prefix = "𝑓/"
  end
end
