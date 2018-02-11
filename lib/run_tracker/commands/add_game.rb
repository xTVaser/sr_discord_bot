module RunTracker
  module CommandLoader
    module AddGame
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:addgame, description: 'Add a game to the list of tracked games.',
                        usage: "#{PREFIX}addgame <id/name> <game-name/game-id>",
                        permission_level: PERM_ADMIN,
                        min_args: 2,
                        max_args: 2,
                        bucket: :limiter) do |_event, type, search_field|

        # Command Body
        # Check to see if the command syntax was valid
        unless type.casecmp('id').zero? || type.casecmp('name').zero?
          _event << 'Invalid syntax for command `addgame`!'
          _event << "Usage: `#{PREFIX}addgame <id/name> <game-name/game-id>`"
          next
        end

        # If the user wants to search by ID, check for ID with SRC API
        # http://www.speedrun.com/api/v1/games/<id>
        if type.casecmp('id').zero?
          trackGame(_event, search_field)
        # However if the user wants to lookup by game, we just get all the results, and make them re-query if >1.
        # http://www.speedrun.com/api/v1/games?name=<name>
        elsif type.casecmp('name').zero?
          results = Util.jsonRequest("#{SrcAPI::API_URL}games?name=#{search_field}&orderby=name.int&direction=asc")['data']
          if results.empty? # no results
            _event << 'No games found with that search criteria, try again'
            next
          elsif results.length > 1 # more than 1 result

            message = Array.new
            message.push("Found `#{results.length}` results with the criteria: `#{search_field}`, re-call with correct ID:")
            count = 1
            results.each do |game| # Print all results out
              message.push("[#{count}] ID: `#{game['id']}` - #{game['names']['international']}")
              count += 1
            end
            Util.safeArrayToMesage(message, _event)

          else # only 1 result
            trackGame(_event, results.first['id'])
          end
        else
          _event << "Usage: `#{PREFIX}addgame <id/name> <game-name/game-id>`"
          next
        end
      end # end command body

      # Adds a single game to the tracked-games DB
      def self.trackGame(_event, id)
        # Check to see if we have added this game already or not
        trackedGame = SQLiteDB.getTrackedGame(id)
        if trackedGame != nil
          _event << "That game is already being tracked, remove it first."
          return
        end
        begin
          json = Util.jsonRequest("#{SrcAPI::API_URL}games/#{id}")
          RTBot.send_message(_event.channel.id, 'Archiving Existing Runs...This can Take a While...')
          addGameResults = SrcAPI.getGameInfoFromID(json)
          trackedGame = addGameResults.last
          gameAlias = addGameResults.first
        rescue Exception => e
          puts "[ERROR] #{e.message} #{e.backtrace}"
          return
        end
        trackedGame.announce_channel = _event.channel
        pass = SQLiteDB.insertNewTrackedGame(trackedGame)
        unless pass
          _event << "That game is already being tracked, remove it first."
          return
        end

        # Announce to user
        embed = Discordrb::Webhooks::Embed.new(
            title: "Game Added",
            description: "Found **#{trackedGame.name}** with Speedrun.com ID: **#{trackedGame.id}**.\nArchived **#{trackedGame.categories.length}** categories and **#{trackedGame.moderators.length}** moderators.",
            thumbnail: {
              url: trackedGame.cover_url
            },
            footer: {
              text: "#{PREFIX}help to view a list of available commands"
            }
        )
        embed.colour = "#35f904"
        embed.add_field(
          name: "To Change Alias",
          value: "#{PREFIX}setgamealias #{gameAlias} <newAlias>",
          inline: false
        )
        embed.add_field(
          name: "To Change Announce Channel",
          value: "#{PREFIX}setannounce #{gameAlias} <#channel_name>",
          inline: false
        )
        embed.add_field(
          name: "To Remove",
          value: "#{PREFIX}removegame #{gameAlias}",
          inline: false
        )
        RTBot.send_message(_event.channel.id, "", false, embed)

      end # end self.trackGame
    end
  end
end
