require "exiftool_vendored"

require_relative "../nanoc_transformable"

module PhillipRidlen
  module DataSources
    class Exif < Nanoc::DataSource
      class Item
        # Provides `to_nanoc_item` for binary items
        include NanocTransformable::Binary

        attr_reader :attributes

        def initialize(filename)
          @exif = Exiftool.new(filename).to_hash.freeze
          @attributes = build_attributes
        end

        private def build_attributes
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
            f_stop: "𝑓/#{exif(:f_number)}",
            # Exposure time in seconds, with fancy "𝑠"
            exposure: "#{exif(:exposure_time)}𝑠",
            # ISO number
            iso: exif(:iso),
          }.transform_values(&:freeze).freeze
        end

        private def exif(key)
          @exif.fetch(key)
        end

        private def replace_f_stop(str)
          str.gsub("f/", "𝑓/")
        end

        private def parse_exif_date(exif_date_str)
          Time.strptime(exif_date_str, "%Y:%m:%d %H:%M:%S")
        end
      end
    end
  end
end
