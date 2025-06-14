require "freshrss/link_extractors/daring_fireball"

RSpec.describe FreshRSS::LinkExtractors::DaringFireball do
  subject { described_class.new }

  it "returns nil for non DF entries" do
    expect(subject.call({"origin" => {"title" => "Other"}})).to be_nil
  end

  it "extracts linked list permalink" do
    entry = {
      "origin" => {"title" => "Daring Fireball"},
      "content" => {"content" => "<a href='https://daringfireball.net/linked/2024/06/01/foo'>x</a>"}
    }
    expect(subject.call(entry)).to eq("https://daringfireball.net/linked/2024/06/01/foo")
  end

  it "falls back to originId" do
    entry = {
      "origin" => {"title" => "Daring Fireball"},
      "summary" => {"content" => "<p>No link</p>"},
      "originId" => "https://daringfireball.net/2024/01/01/foo"
    }
    expect(subject.call(entry)).to eq("https://daringfireball.net/2024/01/01/foo")
  end
end
