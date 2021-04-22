require "rmagick"

class Thumbnailize < Nanoc::Filter
  identifier :thumbnailize
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
