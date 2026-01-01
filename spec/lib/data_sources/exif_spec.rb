require "tmpdir"
require "fileutils"
require "data_sources/exif"

RSpec.describe DataSources::Exif do
  let(:tmpdir) { Dir.mktmpdir }

  after do
    FileUtils.remove_entry(tmpdir)
  end

  subject do
    described_class.new({}, "/", "/", content_dir: tmpdir, ext: %w[jpg])
  end

  it "builds Nanoc items populated from EXIF metadata for each photo" do
    photo_specs = {
      "sunset.jpg" => {
        title: "Sunset",
        description: "Nice photo",
        timestamp: Time.new(2024, 1, 2, 3, 4, 5),
        make: "Canon",
        model: "EOS",
        lens_info: "f/1.8",
        f_number: "1.8",
        exposure_time: "1/250",
        iso: 200
      },
      "flower.jpg" => {
        title: "Flower",
        description: "Macro shot",
        timestamp: Time.new(2023, 7, 4, 5, 6, 7),
        make: "Nikon",
        model: "D850",
        lens_info: "f/2.8",
        f_number: "2.8",
        exposure_time: "1/60",
        iso: 800
      }
    }

    raw_exif_data = {}

    photo_specs.each do |filename, spec|
      path = File.join(tmpdir, filename)
      File.write(path, "binary-data")

      raw_exif_data[filename] = {
        headline: spec[:title],
        "caption-abstract": spec[:description],
        date_time_original: spec[:timestamp].strftime("%Y:%m:%d %H:%M:%S"),
        source_file: path,
        make: spec[:make],
        model: spec[:model],
        lens_info: spec[:lens_info],
        f_number: spec[:f_number],
        exposure_time: spec[:exposure_time],
        iso: spec[:iso]
      }
    end

    allow(Exiftool).to receive(:new) do |path|
      basename = File.basename(path)
      instance_double("Exiftool", to_hash: raw_exif_data.fetch(basename))
    end

    items = subject.items
    expect(items.size).to eq(photo_specs.size)

    items.each do |item|
      basename = File.basename(item.attributes[:filename])
      spec = photo_specs.fetch(basename)

      expect(item.identifier.to_s).to end_with(basename)
      expect(item.attributes[:title]).to eq(spec[:title])
      expect(item.attributes[:description]).to eq(spec[:description])
      expect(item.attributes[:date]).to eq(spec[:timestamp])
      expect(item.attributes[:camera]).to eq("#{spec[:make]} #{spec[:model]}")
      expect(item.attributes[:lens]).to eq(spec[:lens_info].sub("f/", "𝑓/"))
      expect(item.attributes[:f_stop]).to eq("𝑓/#{spec[:f_number]}")
      expect(item.attributes[:exposure]).to eq("#{spec[:exposure_time]}𝑠")
      expect(item.attributes[:iso]).to eq(spec[:iso])
    end
  end
end
