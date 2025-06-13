require 'data_sources/freshrss'
require 'tmpdir'
require 'yaml'

RSpec.describe DataSources::FreshRSS do
  let(:tmpdir) { Dir.mktmpdir }
  let(:config) do
    {
      url: 'https://example.com',
      username: 'user',
      api_password: 'pass',
      content_dir: tmpdir,
      limit: 50,
    }
  end
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
    }
  end

  before do
    client = instance_double(FreshRSS::Client)
    allow(FreshRSS::Client).to receive(:new).and_return(client)
    allow(client).to receive(:starred).with(limit: 50).and_return(response)
  end

  after do
    FileUtils.remove_entry(tmpdir)
  end

  it 'writes new items to markdown' do
    subject.items
    encoded_id = Base64.urlsafe_encode64('tag:example.com,2024:item/1', padding: false)
    file = File.join(tmpdir, "#{encoded_id}.md")
    expect(File).to exist(file)
    content = File.read(file)
    yaml = content[/\A---\n(.*?)\n---/m, 1]
    data = YAML.safe_load(yaml)
    expect(data['title']).to eq('Test')
    expect(data['url']).to eq('https://example.com/story')
    expect(data['source']).to eq('FreshRSS')
  end

  it 'sanitizes ids (urlsafe base64)' do
    expect(subject.send(:sanitize_id, 'a/b?c')).to eq("YS9iP2M")
  end

  it 'skips when file exists' do
    encoded_id = Base64.urlsafe_encode64('tag:example.com,2024:item/1', padding: false)
    file = File.join(tmpdir, "#{encoded_id}.md")
    FileUtils.mkdir_p(tmpdir)
    File.write(file, 'old')
    subject.items
    expect(File.read(file)).to eq('old')
  end
end
