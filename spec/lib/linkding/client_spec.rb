require "linkding/client"

RSpec.describe Linkding::Client do
  subject { described_class.new(instance_url: "https://ld.example", token: "t") }

  it "requests bookmarks" do
    uri = URI("https://ld.example/api/bookmarks/")
    params = {limit: 10, q: "#foo #bar"}
    uri.query = URI.encode_www_form(params)

    request = instance_double(Net::HTTP::Get)
    expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)
    expect(request).to receive(:[]=).with("Authorization", "Token t")

    http = double
    response = double(body: '{"results":[]}')
    expect(Net::HTTP).to receive(:start).with(uri.host, uri.port, use_ssl: true).and_yield(http)
    expect(http).to receive(:request).with(request).and_return(response)

    result = subject.bookmarks(tags: %w[foo bar], limit: 10)
    expect(result).to eq("results" => [])
  end

  it "can receive a config object or parameters" do
    config = Linkding::Config.new(token: "t")
    expect(described_class.new(config)).to be_a(Linkding::Client)

    both = described_class.new(config, token: "x")
    new_config = both.instance_variable_get(:@config)
    expect(new_config.token).to eq("x")
  end
end
