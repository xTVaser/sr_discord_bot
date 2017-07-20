require "spec_helper"

RSpec.describe SrDiscordBot do
  it "has a version number" do
    expect(SrDiscordBot::VERSION).not_to be nil
  end

  it "has a URL to the public git repo" do
    expect(SrDiscordBot::Url).to eq("https://github.com/xTVaser/sr_discord_bot")
  end
end
