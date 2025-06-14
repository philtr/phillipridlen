require "data_sources/linkding"
require "tmpdir"
require "yaml"

RSpec.describe DataSources::Linkding do
  let(:tmpdir) { Dir.mktmpdir }
  let(:config) do
    {
      url: "https://ld.example",
      token: "t",
      tags: ["ruby"],
      content_dir: tmpdir,
      limit: 100
    }
  end
  subject { described_class.new({text_extensions: ["md"]}, "/", "/", config) }

  let(:response) do
    {
      "results" => [
        {
          "id" => 1,
          "url" => "https://example.com",
          "title" => "Title",
          "description" => "Body",
          "date_added" => "2024-01-01T00:00:00Z"
        }
      ]
    }
  end

  before do
    client = instance_double(Linkding::Client)
    allow(Linkding::Client).to receive(:new).and_return(client)
    allow(client).to receive(:bookmarks).with(tags: ["ruby"], limit: 100).and_return(response)
  end

  after do
    FileUtils.remove_entry(tmpdir)
  end

  it "writes new bookmarks to markdown" do
    subject.items
    encoded_id = Base64.urlsafe_encode64("1", padding: false)
    file = File.join(tmpdir, "#{encoded_id}.md")
    expect(File).to exist(file)
    yaml = File.read(file)[/\A---\n(.*?)\n---/m, 1]
    data = YAML.safe_load(yaml)
    expect(data["title"]).to eq("Title")
    expect(data["url"]).to eq("https://example.com")
    expect(data["source"]).to eq("Linkding")
  end

  it "sanitizes ids (urlsafe base64)" do
    expect(subject.send(:sanitize_id, "a/b?c")).to eq("YS9iP2M")
  end

  it "skips when file exists" do
    encoded_id = Base64.urlsafe_encode64("1", padding: false)
    file = File.join(tmpdir, "#{encoded_id}.md")
    FileUtils.mkdir_p(tmpdir)
    File.write(file, "old")
    subject.items
    expect(File.read(file)).to eq("old")
  end
end
