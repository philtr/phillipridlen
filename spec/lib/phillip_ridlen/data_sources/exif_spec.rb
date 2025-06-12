require 'phillip_ridlen/data_sources/exif'

RSpec.describe PhillipRidlen::DataSources::Exif do
  subject do
    described_class.new({}, '/', '/', content_dir: 'photos', ext: %w[jpg png])
  end

  it 'builds a file glob from config' do
    expect(subject.file_glob).to end_with('/**/*.{jpg,png}')
  end

  it 'returns extension array' do
    expect(subject.ext).to eq(%w[jpg png])
  end
end
