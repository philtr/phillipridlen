require 'data_sources/exif'
require 'data_sources/exif/item'

RSpec.describe DataSources::Exif::Item do
  let(:exif_hash) do
    {
      image_description: 'Sunset',
      user_comment: 'Nice photo',
      date_time_original: '2024:01:02 03:04:05',
      source_file: '/tmp/photo.jpg',
      make: 'Canon',
      model: 'EOS',
      lens_info: 'f/1.8',
      f_number: '1.8',
      exposure_time: '1/250',
      iso: 200
    }
  end

  before do
    exiftool = instance_double('Exiftool', to_hash: exif_hash)
    allow(Exiftool).to receive(:new).and_return(exiftool)
  end

  subject { described_class.new('/tmp/photo.jpg') }

  it 'parses attributes from exif data' do
    attrs = subject.attributes
    expect(attrs[:title]).to eq('Sunset')
    expect(attrs[:description]).to eq('Nice photo')
    expect(attrs[:date]).to eq(Time.new(2024,1,2,3,4,5))
    expect(attrs[:filename]).to eq('/tmp/photo.jpg')
    expect(attrs[:camera]).to eq('Canon EOS')
    expect(attrs[:lens]).to eq("𝑓/1.8")
    expect(attrs[:f_stop]).to eq("𝑓/1.8")
    expect(attrs[:exposure]).to eq('1/250𝑠')
    expect(attrs[:iso]).to eq(200)
  end
end
