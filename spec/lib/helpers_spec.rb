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

  describe "#post_asset_output_path" do
    it "builds the asset path for a provided post" do
      post = {
        category: "Life",
        date: Time.new(2025, 12, 27),
        slug: "a-post"
      }

      expect(post_asset_output_path("photo.jpg", post)).to eq(
        "/notes/life/2025/12/27/a-post/photo.jpg"
      )
    end
  end

  describe "#post_summary" do
    it "prefers a description and decodes HTML entities" do
      post = double(description: "A writer&rsquo;s description", excerpt: "An excerpt")
      allow(post).to receive(:[]).with(:description).and_return("A writer&rsquo;s description")
      allow(post).to receive(:[]).with(:excerpt).and_return("An excerpt")

      expect(post_summary(post)).to eq("A writer’s description")
    end

    it "falls back to a legacy excerpt" do
      post = double
      allow(post).to receive(:[]).with(:description).and_return(nil)
      allow(post).to receive(:[]).with(:excerpt).and_return("Legacy excerpt")

      expect(post_summary(post)).to eq("Legacy excerpt")
    end

    it "extracts and truncates the first body paragraph" do
      long_paragraph = ("word " * 60).strip
      post = double(raw_content: "# Heading\n\n#{long_paragraph}\n\nSecond paragraph.")
      allow(post).to receive(:[]).with(:description).and_return(nil)
      allow(post).to receive(:[]).with(:excerpt).and_return(nil)

      summary = post_summary(post)
      expect(summary).to end_with("…")
      expect(summary.length).to be <= 240
      expect(summary).not_to include("Second paragraph")
    end
  end

  describe "#post_card_image" do
    let(:post) do
      double(
        identifier: "/posts/notes/2025/12/a-post/index.md",
        category: "Life",
        date: Time.new(2025, 12, 27),
        slug: "a-post"
      )
    end

    before do
      allow(post).to receive(:[]).with(:category).and_return("Life")
      allow(post).to receive(:[]).with(:date).and_return(Time.new(2025, 12, 27))
      allow(post).to receive(:[]).with(:slug).and_return("a-post")
      allow(post).to receive(:fetch).with(:date).and_return(Time.new(2025, 12, 27))
    end

    it "returns nil when there is no featured media" do
      allow(post).to receive(:[]).with(:image).and_return(nil)

      expect(post_card_image(post)).to be_nil
    end

    it "resolves a local image to the post output path" do
      allow(post).to receive(:[]).with(:image).and_return("photo.jpg")

      expect(post_card_image(post)).to eq(
        "/notes/life/2025/12/27/a-post/photo.jpg"
      )
    end

    it "uses a sibling GIF as the preview for video media" do
      allow(post).to receive(:[]).with(:image).and_return("preview.mp4")
      gif = double(identifier: "/posts/notes/2025/12/a-post/preview.gif")
      @items = [gif]

      expect(post_card_image(post)).to eq(
        "/notes/life/2025/12/27/a-post/preview.gif"
      )
    end

    it "omits video media without a sibling GIF" do
      allow(post).to receive(:[]).with(:image).and_return("preview.mp4")

      expect(post_card_image(post)).to be_nil
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

  describe "#favicon_url" do
    it "builds a Google favicon service URL for the given site URL" do
      expect(favicon_url("https://daringfireball.net/")).to eq(
        "https://www.google.com/s2/favicons?sz=64&domain_url=https%3A%2F%2Fdaringfireball.net%2F"
      )
    end

    it "uses the override when one is provided" do
      expect(
        favicon_url("https://hudlow.org/", override: "https://hudlow.org/favicon.ico?v1")
      ).to eq("https://hudlow.org/favicon.ico?v1")
    end
  end

  describe "#icon" do
    it "returns svg markup for a known icon" do
      expect(icon(:rss)).to include("<svg")
      expect(icon(:youtube)).to include('fill="#ff0000"')
    end

    it "raises for an unknown icon" do
      expect { icon(:wat) }.to raise_error(ArgumentError, /Unknown icon/)
    end
  end

  describe "#site_rss_link" do
    it "returns a link to the site atom feed with the RSS icon" do
      expect(site_rss_link).to include('href="/atom.xml"')
      expect(site_rss_link).to include("RSS")
      expect(site_rss_link).to include("<svg")
    end
  end
end
