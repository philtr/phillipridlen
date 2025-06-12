require 'filters/binary_text_content'

RSpec.describe BinaryTextContent do
  it 'returns the provided content parameter' do
    filter = described_class.new
    result = filter.setup_and_run('ignored', content: 'hello')
    expect(result).to eq('hello')
  end
end
