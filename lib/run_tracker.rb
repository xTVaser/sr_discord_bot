#  Gemfile plugins
require 'dotenv'
require 'discordrb'
require 'pp'

# Bot Documentation - http://www.rubydoc.info/gems/discordrb

# All code in the gem is namespaced under this module.
module RunTracker
  require_relative 'run_tracker/version'
  require_relative 'db/psql_database'

  Dotenv.load('vars.env')

  # Establish Discord Bot Connection
  RTBot = Discordrb::Commands::CommandBot.new(token: ENV['TOKEN'],
                                              client_id: ENV['CLIENT_ID'],
                                              prefix: '!')

  DevChannelID = 338_452_338_912_264_192

  RTBot.ready do |_event|
    RTBot.send_message(DevChannelID, '!! Bot Back Online !!')
  end

  # Require all files in run_tracker folder
  Dir["#{File.dirname(__FILE__)}/run_tracker/*.rb"].each do |file|
    require file
  end

  require_relative 'run_tracker/models/tracked_game'

  # Load up all the commands
  CommandLoader.loadCommands

  # If the Bot is connecting to the server for the first time
  # it should establish the database schema, would be nice to
  # not have to call this manually but whatever.

  # TODO: Temporary commands below, remove after devel or move to safe environment with permissions checking
  RTBot.message(with_text: '!CreateSchema') do |event|
    event.respond 'k 1 sec'
    event.respond PostgresDB.generateSchema
  end

  RTBot.message(with_text: '!DestroySchema yesiamsure') do |event|
    event.respond "k hope you know what you're doing"
    event.respond PostgresDB.destroySchema
  end

  RTBot.run
end
