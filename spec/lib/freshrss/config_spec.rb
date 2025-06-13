require "spec_helper"
require "freshrss/config"

describe FreshRSS::Config do
  it "yields itself in the constructor" do
    config = FreshRSS::Config.new do |freshrss|
      freshrss.instance_url = "https://freshrss.example.com"
      freshrss.username = "username"
      freshrss.api_password = "password"
    end

    expect(config.instance_url).to eq("https://freshrss.example.com")
    expect(config.username).to eq("username")
    expect(config.api_password).to eq("password")
  end

  it "accepts a hash of parameters" do
    config = FreshRSS::Config.new({
      instance_url: "https://freshrss.example.com",
      username: "username",
      api_password: "password"
    })

    expect(config.instance_url).to eq("https://freshrss.example.com")
    expect(config.username).to eq("username")
    expect(config.api_password).to eq("password")
  end

  it "accepts a mixed hash and block" do
    config = FreshRSS::Config.new(username: "username") do |freshrss|
      freshrss.instance_url = "https://freshrss.example.com"
      freshrss.api_password = "password"
    end

    expect(config.instance_url).to eq("https://freshrss.example.com")
    expect(config.username).to eq("username")
    expect(config.api_password).to eq("password")
  end
end
