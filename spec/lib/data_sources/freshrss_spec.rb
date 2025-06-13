require 'data_sources/freshrss'
require 'tmpdir'
require 'yaml'

RSpec.describe DataSources::FreshRSS do
  let(:tmpdir) { Dir.mktmpdir }
  let(:config) { { url: 'https://example.com/api', content_dir: tmpdir, limit: 50 } }
  subject { described_class.new({ text_extensions: ['md'] }, '/', '/', config) }

  let(:response) do
    {
      'items' => [
        {
          'id' => 'tag:example.com,2024:item/1',
          'title' => 'Test',
          'alternate' => [{ 'href' => 'https://example.com/story' }],
          'published' => 1,
          'content' => 'Body'
        }
      ]
    }.to_json
  end

  before do
    uri = URI('https://example.com/api')
    uri.query = URI.encode_www_form(n: 50)
    allow(Net::HTTP).to receive(:get).with(uri).and_return(response)
  end

  after do
    FileUtils.remove_entry(tmpdir)
  end

  it 'writes new items to markdown' do
    subject.items
    file = File.join(tmpdir, 'tag_example_com_2024_item_1.md')
    expect(File).to exist(file)
    content = File.read(file)
    yaml = content[/\A---\n(.*?)\n---/m, 1]
    data = YAML.safe_load(yaml)
    expect(data['title']).to eq('Test')
    expect(data['url']).to eq('https://example.com/story')
    expect(data['source']).to eq('FreshRSS')
  end

  it 'sanitizes ids' do
    expect(subject.send(:sanitize_id, 'a/b?c')).to eq('a_b_c')
  end

  it 'skips when file exists' do
    file = File.join(tmpdir, 'tag_example_com_2024_item_1.md')
    FileUtils.mkdir_p(tmpdir)
    File.write(file, 'old')
    subject.items
    expect(File.read(file)).to eq('old')
  end
end
