require "filters/haml"

RSpec.describe NanocFilters::Haml do
  it "renders Haml templates" do
    filter = described_class.new(name: "World")
    result = filter.setup_and_run('%p= "Hello #{name}"')
    expect(result.strip).to eq("<p>Hello World</p>")
  end
end
