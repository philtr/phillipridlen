require "link_extractors/default"

RSpec.describe LinkExtractors::Default do
  subject { described_class.new }

  it "returns alternate href when present" do
    entry = {"alternate" => [{"href" => "https://example.com"}]}
    expect(subject.call(entry)).to eq("https://example.com")
  end

  it "falls back to originId" do
    entry = {"originId" => "https://example.org"}
    expect(subject.call(entry)).to eq("https://example.org")
  end

  it "returns nil when no url" do
    expect(subject.call({})).to be_nil
  end
end
