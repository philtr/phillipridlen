require "spec_helper"
require "linkding/config"

describe Linkding::Config do
  it "yields itself in the constructor" do
    config = Linkding::Config.new do |ld|
      ld.instance_url = "https://linkding.example.com"
      ld.token = "token"
    end

    expect(config.instance_url).to eq("https://linkding.example.com")
    expect(config.token).to eq("token")
  end

  it "accepts a hash of parameters" do
    config = Linkding::Config.new({instance_url: "https://linkding.example.com", token: "token"})

    expect(config.instance_url).to eq("https://linkding.example.com")
    expect(config.token).to eq("token")
  end

  it "accepts a mixed hash and block" do
    config = Linkding::Config.new(token: "token") do |ld|
      ld.instance_url = "https://linkding.example.com"
    end

    expect(config.instance_url).to eq("https://linkding.example.com")
    expect(config.token).to eq("token")
  end
end
