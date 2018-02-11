module RunTracker
  module CommandLoader
    module RemoveGame
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:removegame, description: 'Removes a game from the list of tracked games.',
                           usage: '~removegame <game-alias>',
                           permission_level: PERM_ADMIN,
                           rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                           bucket: :limiter,
                           min_args: 1,
                           max_args: 1) do |_event, _gameAlias|

        # Check to see if the game is even tracked
        gameID = SQLiteDB.findID(_gameAlias)
        if gameID == nil
          _event << "That game is not currently being tracked"
          next
        end

        begin
            SQLiteDB::Conn.transaction
            # Delete the tracked game information
            SQLiteDB::Conn.execute('DELETE from tracked_games where game_id = "?"', gameID)
            SQLiteDB::Conn.execute('DELETE from categories where game_id = "?"', gameID)
            SQLiteDB::Conn.execute('DELETE from moderators where game_id = "?"', gameID)

            # Go through all of the runners and delete the tracked game
            runners = SQLiteDB.getCurrentRunners
            runners.each do |key, runner|
              # If the runner hasnt played that game, forget about it
              if !runner.historic_runs.key?(gameID)
                next
              end
              # Else we have to get the stats so we can correct those as well
              game = runner.historic_runs[gameID]
              runner.num_submitted_wrs -= game.num_previous_wrs
              runner.num_submitted_runs -= game.num_submitted_runs
              runner.total_time_overall -= game.total_time_overall
              # Now delete the game
              runner.historic_runs.delete(gameID)
            end
            # Update their fields
            SQLiteDB.updateCurrentRunners(runners)

            # Delete the game and category aliases
            SQLiteDB::Conn.execute('DELETE from aliases where alias LIKE "?%"', _gameAlias)

            # Delete the game's resources
            SQLiteDB::Conn.execute('DELETE from resources where game_alias = "?"', _gameAlias)
            SQLiteDB::Conn.commit
          rescue Exception => e
            SQLiteDB::Conn.rollback
            puts "[ERROR] #{e.message} #{e.backtrace}"
            _event << "Error while deleting the game."
            next
        end # end of begin

        embed = Discordrb::Webhooks::Embed.new(
            title: "Game Removed Successfully",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#ff0000"
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end of command body
    end
  end
end
