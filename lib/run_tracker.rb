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
                                              prefix: '!',
                                              command_doesnt_exist_message: 'Use !help to see a list of available commands')

  # Constants
  PERM_ADMIN = 2
  PERM_MOD = 1
  PERM_USER = 0

  HEARTBEAT_CHECKRUNS = 1 # 1 heartbeat approximately every 1minute
  HEARTBEAT_NOTIFYMODS = 1

  # When the bot starts up
  RTBot.ready do |_event|
    # Create the database tables
    PostgresDB.generateSchema
    # Initialize any permissions that have previously been set
    PostgresDB.initPermissions
    # Give the server owner maximum permissions
    RTBot.set_user_permission(RTBot.servers.first.last.owner.id, PERM_ADMIN)
    # Hardcode to give me permissions
    RTBot.set_user_permission(140194315518345216, PERM_ADMIN)
    # Clear the notifications table if at 200 rows, delete 150 of the most recent ones
    PostgresDB.cleanNotificationTable
    PostgresDB.cleanAnnouncementsTable

    puts "[INFO] Bot Online and Connected to Server"
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

  heartbeatCounter = 1

  RTBot.heartbeat do |_event|

    heartbeatCounter += 1
    # Every 5th heartbeat, check for new runs
    if heartbeatCounter >= HEARTBEAT_CHECKRUNS
      AnnounceRuns.announceRuns
      # Clean the notification table every so often
      PostgresDB.cleanAnnouncementsTable
    end

    # Every 10th heartbeat, notify the moderators
    if heartbeatCounter >= HEARTBEAT_NOTIFYMODS
      heartbeatCounter = 1
      NotifyMods.notifyMods
      # Clean the notification table every so often
      PostgresDB.cleanNotificationTable
    end
  end

  RTBot.run
end
