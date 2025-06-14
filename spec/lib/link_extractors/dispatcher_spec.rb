require "link_extractors/dispatcher"

RSpec.describe LinkExtractors::Dispatcher do
  it "returns first non-nil result" do
    first = double(call: nil)
    second = double(call: "url")
    dispatcher = described_class.new([first, second])
    expect(dispatcher.call({})).to eq("url")
  end

  it "returns nil when all extractors return nil" do
    dispatcher = described_class.new([double(call: nil)])
    expect(dispatcher.call({})).to be_nil
  end
end
