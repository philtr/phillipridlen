require "data_sources/youtube"
require "tmpdir"
require "yaml"

RSpec.describe DataSources::Youtube do
  let(:tmpdir) { Dir.mktmpdir }
  let(:config) do
    {
      api_key: "k",
      playlists: ["https://www.youtube.com/playlist?list=PL1"],
      content_dir: tmpdir,
      limit: 50
    }
  end
  subject { described_class.new({text_extensions: ["md"]}, "/", "/", config) }

  let(:response) do
    {
      "items" => [
        {
          "id" => "abc",
          "snippet" => {
            "title" => "Video",
            "description" => "Body",
            "publishedAt" => "2024-01-01T00:00:00Z",
            "resourceId" => {"videoId" => "v123"}
          }
        }
      ]
    }
  end

  before do
    client = instance_double(Youtube::Client)
    allow(Youtube::Client).to receive(:new).and_return(client)
    allow(client).to receive(:playlist_items).with("PL1", limit: 50).and_return(response)
  end

  after do
    FileUtils.remove_entry(tmpdir)
  end

  it "writes new items to markdown" do
    subject.items
    encoded_id = Base64.urlsafe_encode64("abc", padding: false)
    file = File.join(tmpdir, "#{encoded_id}.md")
    expect(File).to exist(file)
    yaml = File.read(file)[/\A---\n(.*?)\n---/m, 1]
    data = YAML.safe_load(yaml)
    expect(data["title"]).to eq("Video")
    expect(data["url"]).to eq("https://www.youtube.com/watch?v=v123")
    expect(data["source"]).to eq("YouTube")
  end

  it "sanitizes ids (urlsafe base64)" do
    expect(subject.send(:sanitize_id, "a/b?c")).to eq("YS9iP2M")
  end

  it "skips when file exists" do
    encoded_id = Base64.urlsafe_encode64("abc", padding: false)
    file = File.join(tmpdir, "#{encoded_id}.md")
    FileUtils.mkdir_p(tmpdir)
    File.write(file, "old")
    subject.items
    expect(File.read(file)).to eq("old")
  end
end
