require "data_sources/exif"
require "rmagick"
require "tmpdir"

RSpec.describe DataSources::Exif do
  let(:tmpdir) { Dir.mktmpdir }
  let(:filename) { File.join(tmpdir, "test.jpg") }

  before do
    # Create a tiny image
    image = Magick::ImageList.new
    image.new_image(1, 1)
    image.write(filename)

    # Add EXIF data using the vendored exiftool
    exiftool = Exiftool.command
    system(exiftool, "-overwrite_original",
      "-Headline=Sunset",
      "-Caption-Abstract=Nice photo",
      "-DateTimeOriginal=2024:01:02 03:04:05",
      "-Make=Canon",
      "-Model=EOS",
      "-LensInfo=50 50 1.8 1.8",
      "-FNumber=1.8",
      "-ExposureTime=1/250",
      "-ISO=200",
      filename)
  end

  after do
    FileUtils.remove_entry(tmpdir)
  end

  it "reads attributes from exif metadata" do
    ds = described_class.new({}, "/", "/", content_dir: tmpdir, ext: %w[jpg])
    item = ds.items.first
    attrs = item.attributes

    expect(attrs[:title]).to eq("Sunset")
    expect(attrs[:description]).to eq("Nice photo")
    expect(attrs[:date]).to eq(Time.new(2024, 1, 2, 3, 4, 5))
    expect(attrs[:filename]).to eq(filename)
    expect(attrs[:camera]).to eq("Canon EOS")
    expect(attrs[:lens]).to eq("50mm 𝑓/1.8")
    expect(attrs[:f_stop]).to eq("𝑓/1.8")
    expect(attrs[:exposure]).to eq("1/250𝑠")
    expect(attrs[:iso]).to eq(200)
  end
end
