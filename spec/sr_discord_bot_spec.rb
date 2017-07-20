require "spec_helper"

RSpec.describe SrDiscordBot do

  it "Hello World says Hello World" do
    testObj = DiscordBot.new("World")
    result = testObj.sayHi
    expect(result).to eq("Hello World")
  end
end
