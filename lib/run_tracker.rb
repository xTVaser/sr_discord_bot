#  Gemfile plugins
require 'dotenv'
require 'discordrb'

# Local files
require 'run_tracker/version'
require 'db/psql_database'

Dotenv.load('vars.env')

# Bot Documentation - http://www.rubydoc.info/gems/discordrb

# All code in the gem is namespaced under this module.
module RunTracker

  # Establish Discord Bot Connection
  RTBot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], client_id: ENV['CLIENT_ID'], prefix: '!'

  RTBot.ready() do |event|
    event.bot.servers.values.each do |server|
      if server.name == "Dev Server"
        server.text_channels.each do |channel|
          if channel.name == "spam-the-bot"
            channel.send_message("!! Bot Back Online !!")
          end
        end
      end
    end
  end

  # Require all files in run_tracker folder
  Dir["#{File.dirname(__FILE__)}/run_tracker/*.rb"].each {
    |file| require file
  }

  # Load up all the commands
  CommandLoader.loadCommands

  # If the Bot is connecting to the server for the first time
  # it should establish the database schema, would be nice to
  # not have to call this manually but whatever.

  RTBot.message(with_text: '!CreateSchema') do |event|
    event.respond "k 1 sec"
    event.respond PostgresDB.generateSchema
    event.respond "finished"
  end

  RTBot.run
end
