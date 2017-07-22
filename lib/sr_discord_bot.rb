require './sr_discord_bot/version'
require 'dotenv'
require 'discordrb'

Dotenv.load('../vars.env')

#  All code in the gem is namespaced under this class.
class DiscordBot

  bot = Discordrb::Bot.new token: ENV['token'], client_id: ENV['client_id']

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
