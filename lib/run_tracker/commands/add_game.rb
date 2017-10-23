module RunTracker
  module CommandLoader
    module AddGame
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:addgame, description: 'Add a game to the list of tracked games.',
                        usage: '~addgame <id/name> <game-name/game-id>',
                        permission_level: PERM_ADMIN,
                        min_args: 2,
                        max_args: 2,
                        bucket: :limiter) do |_event, type, search_field|

        # Command Body
        # Check to see if the command syntax was valid
        unless type.casecmp('id').zero? || type.casecmp('name').zero?
          _event << 'Invalid syntax for command `addgame`!'
          _event << 'Usage: `~addgame <id/name> <game-name/game-id>`'
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
          _event << 'Usage: `~addgame <id/name> <game-name/game-id>`'
          next
        end
      end # end command body

      # Adds a single game to the tracked-games DB
      def self.trackGame(_event, id)
        # Check to see if we have added this game already or not
        trackedGame = nil
        trackedGame = PostgresDB.getTrackedGame(id)
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
        begin
          PostgresDB::Conn.prepare('add_tracked_games', 'insert into public."tracked_games"
            ("game_id", "game_name", "announce_channel", categories, moderators)
            values ($1, $2, $3, $4, $5)')
          PostgresDB::Conn.exec_prepared('add_tracked_games', [trackedGame.id,
                                                               trackedGame.name, trackedGame.announce_channel.id,
                                                               JSON.generate(trackedGame.categories),
                                                               JSON.generate(trackedGame.moderators)])
          PostgresDB::Conn.exec('DEALLOCATE add_tracked_games')
        rescue PG::UniqueViolation
          _event << "That game is already being tracked, remove it first."
          return
        end

        # Announce to user
        message = Array.new
        message.push("Game Added!")
        message.push("============")
        message.push("Found <#{trackedGame.name}> with ID: <#{trackedGame.id}>")
        message.push("Found <#{trackedGame.categories.length}> categories and <#{trackedGame.moderators.length}> current moderators")
        message.push("To change the alias <~setgamealias #{gameAlias} <newAlias>>")
        message.push("To change the announce channel <~setannounce #{gameAlias} <#channel_name>>")
        message.push("If incorrect, remove with <~removegame #{gameAlias}>")
        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end self.trackGame
    end
  end
end
