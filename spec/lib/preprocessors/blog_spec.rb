require "active_support/core_ext/string"
require "preprocessors/blog"

class ItemCollection
  def initialize
    @items = []
  end

  def <<(item)
    @items << item
  end

  def find_all(pattern)
    if pattern.is_a?(Regexp)
      @items.select { |i| i.identifier =~ pattern }
    else
      @items.select { |i| File.fnmatch(pattern, i.identifier, File::FNM_PATHNAME) }
    end
  end
end

RSpec.describe "blog preprocessors" do
  let(:items) { ItemCollection.new }
  let(:config) { {drafts: false} }

  before do
    @items = items
    @config = config
  end

  describe "#blog_post_attributes_from_filename" do
    it "sets attributes based on filename" do
      item = double(:identifier => "/posts/notes/2024-01-02-test.md", :[]= => nil)
      allow(item).to receive(:[]=)
      items << item
      blog_post_attributes_from_filename
      expect(item).to have_received(:[]=).with(:post_type, "note")
      expect(item).to have_received(:[]=).with(:date, Time.new("2024", "01", "02"))
      expect(item).to have_received(:[]=).with(:slug, "test")
    end

    it "sets slug correctly for posts stored in a directory with index.md" do
      item = double(:identifier => "/posts/notes/2024-01-02-test/index.md", :[]= => nil)
      allow(item).to receive(:[]=)
      items << item
      blog_post_attributes_from_filename
      expect(item).to have_received(:[]=).with(:slug, "test")
    end
  end

  describe "#blog_post_asset_attributes" do
    it "copies metadata from the parent post to assets inside the post directory" do
      post = double(
        :identifier => "/posts/notes/2024-01-02-test/index.md",
        :[] => "Life"
      )
      asset = double(:identifier => "/posts/notes/2024-01-02-test/doomscroll.png", :[]= => nil)

      allow(post).to receive(:[]=)
      allow(post).to receive(:[]).with(:category).and_return("Life")
      allow(asset).to receive(:[]=)

      items << post
      items << asset

      blog_post_asset_attributes

      expect(asset).to have_received(:[]=).with(:post_type, "note")
      expect(asset).to have_received(:[]=).with(:date, Time.new("2024", "01", "02"))
      expect(asset).to have_received(:[]=).with(:slug, "test")
      expect(asset).to have_received(:[]=).with(:category, "Life")
    end
  end

  describe "#blog_post_date_for_drafts" do
    it "assigns date to draft items when drafts enabled" do
      config[:drafts] = true
      draft = double(:draft, identifier: "/drafts/foo.md")
      allow(draft).to receive(:[]=)
      items << draft
      blog_post_date_for_drafts
      expect(draft).to have_received(:[]=).with(:date, kind_of(Time))
    end
  end
end
