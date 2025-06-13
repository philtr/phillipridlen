require 'freshrss/client'

RSpec.describe FreshRSS::Client do
  subject do
    described_class.new(
      base_url: 'https://example.com',
      username: 'u',
      api_password: 'p'
    )
  end

  it 'requests starred items using greader api' do
    uri = URI('https://example.com/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred')
    params = { n: 10, output: 'json' }
    uri.query = URI.encode_www_form(params)

    request = instance_double(Net::HTTP::Get)
    expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)
    expect(request).to receive(:basic_auth).with('u', 'p')

    response = double(body: '{"items":[]}')
    http = double
    expect(Net::HTTP).to receive(:start).with(uri.host, uri.port, use_ssl: true).and_yield(http)
    expect(http).to receive(:request).with(request).and_return(response)

    result = subject.starred(limit: 10)
    expect(result).to eq('items' => [])
  end
end
