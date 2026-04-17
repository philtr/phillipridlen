require "data_sources/blogroll"
require "tmpdir"
require "fileutils"

RSpec.describe DataSources::Blogroll do
  let(:tmpdir) { Dir.mktmpdir }

  subject do
    described_class.new(
      {text_extensions: ["yml"]},
      "/",
      "/",
      content_dir: tmpdir,
      file: "blogroll.yml",
      items_root: "/blogroll/"
    )
  end

  after do
    FileUtils.remove_entry(tmpdir)
  end

  it "loads blogroll entries into Nanoc items" do
    File.write(File.join(tmpdir, "blogroll.yml"), <<~YAML)
      - title: Example
        url: https://example.com/
        rss_url: https://example.com/feed.xml
        note: Example note.
    YAML

    item = subject.items.fetch(0)

    expect(item.attributes[:title]).to eq("Example")
    expect(item.attributes[:url]).to eq("https://example.com/")
    expect(item.attributes[:rss_url]).to eq("https://example.com/feed.xml")
    expect(item.attributes[:position]).to eq(0)
    expect(item.content.string).to eq("Example note.")
    expect(item.identifier.to_s).to eq("/0-example.md")
  end

  it "preserves YAML order through the position attribute" do
    File.write(File.join(tmpdir, "blogroll.yml"), <<~YAML)
      - title: First Entry
        url: https://example.com/1
        rss_url: https://example.com/1/feed.xml
        note: First note.
      - title: Second Entry
        url: https://example.com/2
        rss_url: https://example.com/2/feed.xml
        note: Second note.
    YAML

    items = subject.items

    expect(items.map { |item| item.attributes[:title] }).to eq(["First Entry", "Second Entry"])
    expect(items.map { |item| item.attributes[:position] }).to eq([0, 1])
  end

  it "omits entries marked with display false" do
    File.write(File.join(tmpdir, "blogroll.yml"), <<~YAML)
      - title: Visible Entry
        url: https://example.com/1
        rss_url: https://example.com/1/feed.xml
        note: Visible note.
      - title: Hidden Entry
        url: https://example.com/2
        rss_url: https://example.com/2/feed.xml
        note: Hidden note.
        display: false
    YAML

    items = subject.items

    expect(items.map { |item| item.attributes[:title] }).to eq(["Visible Entry"])
    expect(items.map { |item| item.attributes[:position] }).to eq([0])
  end

  it "raises a clear error when the top-level YAML value is not an array" do
    File.write(File.join(tmpdir, "blogroll.yml"), <<~YAML)
      title: Example
      url: https://example.com/
    YAML

    expect { subject.items }.to raise_error(
      RuntimeError,
      /expects a top-level array/
    )
  end

  it "raises a clear error when required keys are missing" do
    File.write(File.join(tmpdir, "blogroll.yml"), <<~YAML)
      - title: Example
        url: https://example.com/
        note: Missing RSS link.
    YAML

    expect { subject.items }.to raise_error(
      RuntimeError,
      /missing required keys: rss_url/
    )
  end
end
