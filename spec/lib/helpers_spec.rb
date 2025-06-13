# Stub `use_helper` used by `helpers.rb`
def use_helper(*)
  # no-op for testing
end

require "helpers"

RSpec.describe "helpers" do
  before do
    @items = []
    @item = double(attributes: {}, reps: {})
  end

  describe "#body_classes" do
    it "combines body class arrays" do
      @body_classes = ["a"]
      @item = {body_classes: ["b"]}
      expect(body_classes).to eq(%w[a b])
    end
  end

  describe "#posts_sorted_by_date" do
    it "sorts posts by date descending" do
      now = Time.now
      a = {date: now - 1}
      b = {date: now}
      expect(posts_sorted_by_date([a, b])).to eq([b, a])
    end
  end

  describe "#photos_sorted_by_date" do
    it "sorts photos by date descending" do
      now = Time.now
      a = {date: now - 1}
      b = {date: now}
      expect(photos_sorted_by_date([a, b])).to eq([b, a])
    end
  end

  describe "#links_sorted_by_date" do
    it "sorts links by published date descending" do
      now = Time.now
      a = {published: (now - 1).to_s}
      b = {published: now.to_s}
      expect(links_sorted_by_date([a, b])).to eq([b, a])
    end
  end
end
