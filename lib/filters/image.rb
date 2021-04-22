require "rmagick"

module Image
  class ResizeToFill < Nanoc::Filter
    identifier :resize_to_fill
    type :binary

    def run(filename, params = {})
      params = default_params.merge(params)
      image = Magick::ImageList.new(filename)
      image.resize_to_fill!(params[:width], params[:height], params[:gravity])
      image.write(output_filename)
    end

    def default_params
      {
        gravity: Magick::CenterGravity,
      }
    end
  end

  class ResizeToFit < Nanoc::Filter
    identifier :resize_to_fit
    type :binary

    def run(filename, params = {})
      image = Magick::ImageList.new(filename)
      image.resize_to_fit!(params[:width], params[:height])
      image.write(output_filename)
    end
  end
end
