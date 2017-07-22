#  Gemfile plugins
require 'dotenv'
require 'discordrb'

# Local files
require 'sr_discord_bot/version'

Dotenv.load('vars.env')

#  All code in the gem is namespaced under this class.
class DiscordBot

  bot = Discordrb::Bot.new token: ENV['TOKEN'], client_id: ENV['CLIENT_ID']

  bot.message(with_text: 'Bing!') do |event|
    event.respond 'Bing Bong!'
  end
  bot.message(with_text: 'Bing Bing!') do |event|
    event.respond 'Bing Bing Bong Bing!'
  end
  bot.message(with_text: 'Bing Bing Bing!') do |event|
    event.respond 'Bing Bing Bong Bing!'
  end

  bot.run
end
