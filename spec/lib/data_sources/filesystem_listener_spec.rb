require 'data_sources/filesystem_listener'

class DummyListener
  include DataSources::FilesystemListener
  def initialize(config) = @config = config
end

RSpec.describe DataSources::FilesystemListener do
  subject { DummyListener.new(content_dir: 'c', layouts_dir: 'l') }

  it 'returns directories from config' do
    expect(subject.send(:dir_for, :content)).to eq('c')
    expect(subject.send(:dir_for, :layouts)).to eq('l')
  end
end
