#  Gemfile plugins
require 'dotenv'
require 'discordrb'

# Local files
require 'sr_discord_bot/version'

Dotenv.load('vars.env')

#  All code in the gem is namespaced under this class.
class DiscordBot

  bot = Discordrb::Bot.new token: ENV['TOKEN'], client_id: ENV['CLIENT_ID']
  
  bot.ready() do |event|
    event.bot.servers.values.each do |server|
      if server.name == "Dev Server"
        server.text_channels.values.each do |channel|
          if channel.name == "spam-the-bot"
            channel.send_message("!! Bot Back Online !!")
          end
        end
      end
    end
  end

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
