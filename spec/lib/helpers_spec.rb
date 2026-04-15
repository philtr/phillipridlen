# Stub `use_helper` used by `helpers.rb`
def use_helper(*)
  # no-op for testing
end

require "helpers"
RSpec.describe "helpers" do
  before do
    @items = []
    @item = double(attributes: {}, reps: {})
    @config = {kramdown_opts: {}}
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

  describe "#all_posts" do
    it "excludes comments.md items" do
      post = double(identifier: "/posts/notes/2024/01/test/index.md")
      comments = double(identifier: "/posts/notes/2024/01/test/comments.md")

      @items = double(find_all: [post, comments])

      expect(all_posts).to eq([post])
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

  describe "#reader_comments_html" do
    it "returns compiled content from the sibling comments item" do
      item = double(identifier: "/posts/notes/2024/01/test/index.md")
      comments = double(identifier: "/posts/notes/2024/01/test/comments.md", compiled_content: "<p>Hello reader.</p>")
      @items = [comments]

      expect(reader_comments_html(item)).to eq("<p>Hello reader.</p>")
    end

    it "returns nil when the sibling comments item is missing" do
      item = double(identifier: "/posts/notes/2024/01/test/index.md")

      expect(reader_comments_html(item)).to be_nil
    end
  end

  describe "#rss_tracking_pixel" do
    it "returns an img tag with encoded id and path query params" do
      item = double(path: "/notes/programming/2026/04/11/ai-is-making-things-better-but-worse/")
      allow(item).to receive(:fetch).with(:id).and_return("2YG8VYNN5HU6XM0GP6DBFZO8Z0")

      expect(rss_tracking_pixel(item)).to eq(
        '<img src="https://analytics.ptx.sh/p/SjOB3oKbb?id=2YG8VYNN5HU6XM0GP6DBFZO8Z0&url=%2Fnotes%2Fprogramming%2F2026%2F04%2F11%2Fai-is-making-things-better-but-worse%2F" alt="" />'
      )
    end
  end
end
