require "freshrss/client"

RSpec.describe FreshRSS::Client do
  subject do
    described_class.new(
      instance_url: "https://example.com",
      username: "u",
      api_password: "p"
    )
  end

  it "requests starred items using greader api token" do
    login_uri = URI("https://example.com/api/greader.php/accounts/ClientLogin")
    login_request = instance_double(Net::HTTP::Post)
    expect(Net::HTTP::Post).to receive(:new).with(login_uri).and_return(login_request)
    expect(login_request).to receive(:set_form_data).with(Email: "u", Passwd: "p")

    http = double
    login_response = double(body: "SID=token\nLSID=null\nAuth=token\n")
    expect(Net::HTTP).to receive(:start).with(login_uri.host, login_uri.port, use_ssl: true).and_yield(http)
    expect(http).to receive(:request).with(login_request).and_return(login_response)

    uri = URI("https://example.com/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred")
    params = {n: 10, output: "json"}
    uri.query = URI.encode_www_form(params)

    request = instance_double(Net::HTTP::Get)
    expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)
    expect(request).to receive(:[]=).with("Authorization", "GoogleLogin auth=token")

    response = double(body: '{"items":[]}')
    expect(Net::HTTP).to receive(:start).with(uri.host, uri.port, use_ssl: true).and_yield(http)
    expect(http).to receive(:request).with(request).and_return(response)

    result = subject.starred(limit: 10)
    expect(result).to eq("items" => [])
  end

  it "can receive a config object or parameters" do
    config = FreshRSS::Config.new do |freshrss|
      freshrss.instance_url = "https://example.com"
      freshrss.username = "u"
      freshrss.api_password = "p"
    end

    expect(described_class.new(config)).to be_a(FreshRSS::Client)

    both_client = described_class.new(config, api_password: "x")
    both_config = both_client.instance_variable_get(:@config)
    expect(both_config.api_password).to eq("x")
    expect(both_config.instance_url).to eq("https://example.com")
  end
end
