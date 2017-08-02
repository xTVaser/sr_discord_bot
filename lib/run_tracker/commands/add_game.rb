module RunTracker
  module CommandLoader
    module AddGame
      extend Discordrb::Commands::CommandContainer

      command(:addgame, description: 'Add a game to the list of tracked games.',
                        usage: '!addgame <id/name> <game-name/game-id>',
                        min_args: 2,
                        max_args: 2,
                        ) do |event, type, search_field, game_alias| # TODO needs rate limiting added to all these commands

        # Command Body
        # Check to see if the command syntax was valid
        unless type.downcase == "id" or type.downcase == "name"
          RTBot.send_message(DevChannelID, "Invalid syntax for command `addgame`!")
          next RTBot.send_message(DevChannelID, "Usage: `!addgame <id/name> <game-name/game-id>`")
        end

        # If the user wants to search by ID, check for ID with SRC API
        # http://www.speedrun.com/api/v1/games/<id>
        if type.downcase == "id"
          trackGame(event, search_field)
        # However if the user wants to lookup by game, we just get all the results, and make them re-query if >1.
        # http://www.speedrun.com/api/v1/games?name=<name>
        elsif type.downcase == "name"
          results = Util.jsonRequest("#{SrcAPI::API_URL}games?name=#{search_field}")['data']
          pp results
          if results.empty? # no results
            next RTBot.send_message(DevChannelID, "No games found with that search criteria, try again")
          elsif results.length > 1 # more than 1 result
            RTBot.send_message(DevChannelID, "Found `#{results.length}` results with that criteria: #{search_field}, re-call with correct ID:")
            count = 1
            results.each do |game| # Print all results out
              RTBot.send_message(DevChannelID, "[#{count}] ID: `#{game['id']}` - #{game['names']['international']}")
              count += 1
            end
          else # only 1 result
            trackGame(event, results.first['id'])
          end
        else
          RTBot.send_message(DevChannelID, "Usage: `!addgame <id/name> <game-name/game-id>`")
        end
      end

      # Adds a single game to the tracked-games DB
      def self.trackGame(event, id)
        trackedGame = nil
        begin
          json = Util.jsonRequest("#{SrcAPI::API_URL}games/#{id}")
          trackedGame = SrcAPI.getGameInfoFromID(json)
        rescue Exception => e
          RTBot.send_message(DevChannelID, e.backtrace.inspect + e.message + " ID: #{id}") # TODO remove stacktrace stuff
        end
        trackedGame.announce_channel = event.channel

        # TODO Add game to database

        # Announce to user
        RTBot.send_message(DevChannelID, "Found `#{trackedGame.name}` with ID: `#{trackedGame.id}`")
        RTBot.send_message(DevChannelID, "`#{trackedGame.categories.length}` categories and `#{trackedGame.moderators.length}` moderators") # TODO more of a debugging line for now
        RTBot.send_message(DevChannelID, "To change the alias or announce channel : `stub`") # TODO add these
        RTBot.send_message(DevChannelID, "If incorrect, remove with : `stub`") # TODO add remove command
      end

    end
  end
end
