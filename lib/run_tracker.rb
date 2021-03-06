# Gemfile plugins
# Windows Patch for libsodium
if Gem.win_platform?
  ::RBNACL_LIBSODIUM_GEM_LIB_PATH = "F:/Repos/sr_discord_bot/sodium.dll"
end

# require "google/cloud/logging"
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

  # Permission Constants
  PERM_ADMIN = 2
  PERM_MOD = 1
  PERM_USER = 0

  HEARTBEAT_CHECKRUNS = 15 # 1 heartbeat approximately every 1 minute
  HEARTBEAT_NOTIFYMODS = 15

  PREFIX = '$'

  # Require all files in run_tracker folder
  Dir["#{File.dirname(__FILE__)}/run_tracker/*.rb"].each do |file|
    require file
  end

  # Require all model files
  Dir["#{File.dirname(__FILE__)}/run_tracker/models/*.rb"].each do |file|
    require file
  end

  Dotenv.load('vars.env')

  DEBUG_CHANNEL = ENV['DEBUG_CHANNEL']
  if DEBUG_CHANNEL.nil?
    DEBUG_CHANNEL = 351320655540781066
  end
  SETTINGS = Settings.new(DEBUG_CHANNEL)

  rescue_proc = proc do |event, exception|
    embed = Discordrb::Webhooks::Embed.new(
      description: "#{exception}\n\n```#{exception.backtrace}```",
      title: "Uncaught Exception Occurred!"
    )
    embed.colour = "#ff0000"
    RTBot.send_message(SETTINGS.debug_channel_id, "", false, embed)
  end

  # Establish Discord Bot Connection
  RTBot = Discordrb::Commands::CommandBot.new(token: ENV['TOKEN'],
                                              client_id: ENV['CLIENT_ID'],
                                              prefix: PREFIX,
                                              command_doesnt_exist_message: "Use #{PREFIX}help to see a list of available commands",
                                              rescue: rescue_proc)

  # When the bot starts up
  # TODO: Move all logic for databases into the models
  RTBot.ready do |_event|
    RTBot.user(140194315518345216).pm("Bot Online")
    RTBot.game = "#{PREFIX}help for commands"
    # Create the database tables
    SQLiteDB.generateSchema
    # Initialize any permissions that have previously been set
    SQLiteDB.initPermissions
    # Give the server owner maximum permissions
    RTBot.set_user_permission(RTBot.servers.first.last.owner.id, PERM_ADMIN)
    # Hardcode to give me permissions
    # NOTE disable this line if you dont want me to have full access!
    RTBot.set_user_permission(140194315518345216, PERM_ADMIN)
    # As more settings are added, make a generic function for this
    queryResults = SQLiteDB::Conn.execute('SELECT * FROM "settings" LIMIT 1')
    unless queryResults.empty?
      SETTINGS.stream_channel_id = queryResults.first['stream_channel_id'].to_i
      SETTINGS.streamer_role = queryResults.first['streamer_role'].to_i
      unless queryResults.first['exclude_keywords'].nil?
        SETTINGS.exclude_keywords = queryResults.first['exclude_keywords'].split(",")
      end
      unless queryResults.first['allowed_game_list'].nil?
        SETTINGS.allowed_game_list = queryResults.first['allowed_game_list'].split(",")
      end
    end

    Stackdriver.log("Bot Online and Connected to Server")
  end

  # Load up all the commands
  CommandLoader.loadCommands

  announceCounter = 1
  notifyModCounter = 1
  previousDay = Date.today.day

  # RTBot.heartbeat do |_event|

  #   # Every 5th heartbeat, check for new runs
  #   if announceCounter >= HEARTBEAT_CHECKRUNS
  #     AnnounceRuns.announceRuns
  #     announceCounter = 1
  #   end

  #   # Every 10th heartbeat, notify the moderators
  #   # Also check if it's a new day, send a health-check message
  #   if notifyModCounter >= HEARTBEAT_NOTIFYMODS
  #     NotifyMods.notifyMods
  #     notifyModCounter = 1
  #     if previousDay != Date.today.day
  #       RTBot.user(140194315518345216).pm("Bot Online - Assumed Healthy")
  #       previousDay = Date.today.day
  #     end
  #   end
  #   announceCounter += 1
  #   notifyModCounter += 1
  # end

  currently_streaming = Hash.new

  RTBot.playing do |_event|
    if _event.type == nil && currently_streaming[_event.user.id] == true
      currently_streaming[_event.user.id] = nil
    end
    if _event.type == 1
      member = _event.server.member(_event.user.id)
      stream_title = _event.game
      game_name = _event.details
      if currently_streaming[_event.user.id].nil? && (member.role?(SETTINGS.streamer_role) || SETTINGS.streamer_role == 0)
        embed = Discordrb::Webhooks::Embed.new(
          author: {
            name: "Stream Notification",
            url: _event.url,
            icon_url: "https://raw.githubusercontent.com/xTVaser/sr_discord_bot/master/assets/author_icon.png"
          },
          title: "#{_event.user.username} Just Started Streaming",
          url: _event.url,
          thumbnail: {
            url: _event.user.avatar_url
          }
        )
        embed.add_field(
          name: "Stream Title",
          value: stream_title,
          inline: false
        )
        embed.add_field(
          name: "Game Name",
          value: game_name,
          inline: false
        )
        currently_streaming[_event.user.id] = true
        embed.colour = "#6441A4"
        unless SETTINGS.stream_channel_id == 0 || SETTINGS.exclude_keywords.any? { |str| game_name.include? str }
          if (game_name.downcase.include? "jak") || (game_name.downcase.include? "daxter") # || (!SETTINGS.allowed_game_list.include? game_name)
            RTBot.send_message(SETTINGS.stream_channel_id, "", false, embed)
          end
        end
      end
    end
  end

  RTBot.run
end
