require "filters/image"

RSpec.describe Image::ResizeToFill do
  let(:image_double) { double("Magick::ImageList") }

  before do
    allow(Magick::ImageList).to receive(:new).and_return(image_double)
    allow(image_double).to receive(:resize_to_fill!)
    allow(image_double).to receive(:write) do |path|
      FileUtils.touch(path)
    end
  end

  it "resizes and writes the image" do
    filter = described_class.new
    filter.setup_and_run("image.jpg", width: 1, height: 2, gravity: :center)
    expect(Magick::ImageList).to have_received(:new).with("image.jpg")
    expect(image_double).to have_received(:resize_to_fill!).with(1, 2, :center)
    expect(image_double).to have_received(:write).with(filter.output_filename)
  end
end

RSpec.describe Image::ResizeToFit do
  let(:image_double) { double("Magick::ImageList") }

  before do
    allow(Magick::ImageList).to receive(:new).and_return(image_double)
    allow(image_double).to receive(:resize_to_fit!)
    allow(image_double).to receive(:write) do |path|
      FileUtils.touch(path)
    end
  end

  it "resizes and writes the image" do
    filter = described_class.new
    filter.setup_and_run("image.jpg", width: 1, height: 2)
    expect(Magick::ImageList).to have_received(:new).with("image.jpg")
    expect(image_double).to have_received(:resize_to_fit!).with(1, 2)
    expect(image_double).to have_received(:write).with(filter.output_filename)
  end
end
