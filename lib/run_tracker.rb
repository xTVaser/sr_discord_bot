#  Gemfile plugins
require 'dotenv'
require 'discordrb'
require 'pp'

# Bot Documentation - http://www.rubydoc.info/gems/discordrb

# All code in the gem is namespaced under this module.
module RunTracker
  require_relative 'run_tracker/version'
  require_relative 'db/sqlite_database'
  # Require jsonable first because some of the models depend on it
  require_relative 'run_tracker/models/jsonable.rb'

  Dotenv.load('vars.env')

  # Establish Discord Bot Connection
  RTBot = Discordrb::Commands::CommandBot.new(token: ENV['TOKEN'],
                                              client_id: ENV['CLIENT_ID'],
                                              prefix: '~',
                                              command_doesnt_exist_message: 'Use ~help to see a list of available commands')

  # Permission Constants
  PERM_ADMIN = 2
  PERM_MOD = 1
  PERM_USER = 0

  HEARTBEAT_CHECKRUNS = 5 # 1 heartbeat approximately every 1 minute
  HEARTBEAT_NOTIFYMODS = 10

  DEBUG_CHANNEL = ENV['DEBUG_CHANNEL']

  # When the bot starts up
  # TODO Move all logic for databases into the models
  # TODO replace puts with actual logging statements
  # TODO replace all markdown messages with embeds
  # TODO embeds will require me to also store the image!
  RTBot.ready do |_event|
    
    # Create the database tables
    SQLiteDB.generateSchema
    # Initialize any permissions that have previously been set
    SQLiteDB.initPermissions
    # Give the server owner maximum permissions
    RTBot.set_user_permission(RTBot.servers.first.last.owner.id, PERM_ADMIN)
    # Hardcode to give me permissions
    # NOTE disable this line if you dont want me to have full access!
    RTBot.set_user_permission(140194315518345216, PERM_ADMIN)

    puts "[INFO] Bot Online and Connected to Server"
  end

  # Require all files in run_tracker folder
  Dir["#{File.dirname(__FILE__)}/run_tracker/*.rb"].each do |file|
    require file
  end

  # Require all model files
  Dir["#{File.dirname(__FILE__)}/run_tracker/models/*.rb"].each do |file|
    require file
  end

  # Load up all the commands
  CommandLoader.loadCommands

  announceCounter = 1
  notifyModCounter = 1

  RTBot.heartbeat do |_event|

    # Every 5th heartbeat, check for new runs
    if announceCounter >= HEARTBEAT_CHECKRUNS
      AnnounceRuns.announceRuns
      announceCounter = 1
    end

    # Every 10th heartbeat, notify the moderators
    if notifyModCounter >= HEARTBEAT_NOTIFYMODS
      NotifyMods.notifyMods
      notifyModCounter = 1
    end
    announceCounter += 1
    notifyModCounter += 1
  end

  RTBot.run
end
