require "preprocessors/layout"

RSpec.describe "#selected_layout" do
  it "returns layout glob when layout attribute exists" do
    item = {layout: "base"}
    expect(selected_layout(item)).to eq("/base.*")
  end

  it "returns nil when layout attribute missing" do
    expect(selected_layout({})).to be_nil
  end
end
