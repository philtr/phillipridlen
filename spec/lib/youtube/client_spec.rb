require "youtube/client"

RSpec.describe Youtube::Client do
  subject { described_class.new(api_key: "key") }

  it "requests playlist items" do
    uri = URI("https://www.googleapis.com/youtube/v3/playlistItems")
    params = {part: "snippet", playlistId: "PL1", maxResults: 10, key: "key"}
    uri.query = URI.encode_www_form(params)

    request = instance_double(Net::HTTP::Get)
    expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)

    http = double
    response = double(body: '{"items":[]}')
    expect(Net::HTTP).to receive(:start).with(uri.host, uri.port, use_ssl: true).and_yield(http)
    expect(http).to receive(:request).with(request).and_return(response)

    result = subject.playlist_items("PL1", limit: 10)
    expect(result).to eq("items" => [])
  end

  it "can receive a config object or parameters" do
    config = Youtube::Config.new(api_key: "k")
    expect(described_class.new(config)).to be_a(Youtube::Client)

    both = described_class.new(config, api_key: "x")
    new_config = both.instance_variable_get(:@config)
    expect(new_config.api_key).to eq("x")
  end
end
