require "spec_helper"
require "yaml"
require "pry"

RSpec.describe :posts do

  Dir[File.join(File.dirname(__FILE__), "../_posts/**/*.md")].each do |post|
    context post do
      before do
        @post = File.read(post)
        @yaml = @post.split("---")[0..1].join
        @data = YAML.load(@yaml)
      end

      it "should have a layout of 'post'" do
        expect(@data["layout"]).to eq("post")
      end

      it "should be a note or a link" do
        expect(%( note link )).to include(@data["type"])
      end

      it "should have a title" do
        expect(@data["title"]).to_not be_empty
      end

      it "should have an expected category" do
        expect(%( Programming Technology Christianity Food Life )).to include(@data["category"])
      end

      it "should have some tags" do
        expect(@data["tags"]).to be_an(Array)
        expect(@data["tags"].count).to be > 0
      end

      it "should have a source if it's a link" do
        if @data["type"] == "link"
          expect(@data["link"]).to have_key("source")
          expect(@data["link"]["source"]).to match(/^http/)
        end
      end
    end
  end
end
