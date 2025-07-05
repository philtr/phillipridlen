require "preprocessors/games"

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

  def create(content, attributes, identifier)
    item = ItemDouble.new(identifier, content, attributes)
    @items << item
    item
  end
end

class ItemDouble
  attr_reader :identifier, :raw_content, :attributes

  def initialize(identifier, raw_content = "", attributes = {})
    @identifier = identifier
    @raw_content = raw_content
    @attributes = attributes
  end

  def []=(key, value)
    @attributes[key] = value
  end

  def [](key)
    @attributes[key]
  end
end

RSpec.describe "games preprocessors" do
  let(:items) { ItemCollection.new }

  before do
    @items = items
  end

  describe "#game_attributes_from_filename" do
    it "sets slug and version" do
      item = ItemDouble.new("/games/dodgeball/202507011516.md")
      items << item
      game_attributes_from_filename
      expect(item[:slug]).to eq("dodgeball")
      expect(item[:version]).to eq("202507011516")
    end
  end

  describe "#game_latest_items" do
    it "creates an index item for the latest version" do
      older = ItemDouble.new("/games/dodgeball/202507011516.md", "old")
      latest = ItemDouble.new("/games/dodgeball/202507051234.md", "new")
      items << older
      items << latest
      game_attributes_from_filename
      game_latest_items
      index = items.find_all("/games/dodgeball/index.md").first
      expect(index.raw_content).to eq("new")
      expect(index.attributes[:slug]).to eq("dodgeball")
      expect(index.attributes[:version]).to eq("202507051234")
    end
  end
end
