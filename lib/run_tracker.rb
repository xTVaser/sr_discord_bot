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
  # Constants
  PERM_ADMIN = 2
  PERM_MOD = 1
  PERM_USER = 0

  # When the bot starts up
  RTBot.ready do |_event|
    # Create the database tables
    PostgresDB.generateSchema
    # Initialize any permissions that have previously been set
    PostgresDB.initPermissions
    # Give the server owner maximum permissions
    RTBot.set_user_permission(RTBot.servers.first.last.owner.id, PERM_ADMIN)
    RTBot.send_message(DevChannelID, '!! Bot Back Online !!') # TODO remove
  end

  # Require all files in run_tracker folder
  Dir["#{File.dirname(__FILE__)}/run_tracker/*.rb"].each do |file|
    require file
  end

  # Require jsonable first because some of the models depend on it
  require_relative 'run_tracker/models/jsonable.rb'
  # Require all model files
  Dir["#{File.dirname(__FILE__)}/run_tracker/models/*.rb"].each do |file|
    require file
  end

  # Load up all the commands
  CommandLoader.loadCommands

  # If the Bot is connecting to the server for the first time
  # it should establish the database schema, would be nice to
  # not have to call this manually but whatever.

  RTBot.run
end
