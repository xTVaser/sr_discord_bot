module RunTracker
  module CommandLoader
    module RemoveGame
      extend Discordrb::Commands::CommandContainer

      command(:removegame, description: 'Removes a game from the list of tracked games.',
                           usage: '!removegame <game-alias>',
                           permission_level: PERM_ADMIN,
                           min_args: 1,
                           max_args: 1) do |_event, _gameAlias|

        # Check to see if the game is even tracked
        gameID = PostgresDB.findID(_gameAlias)
        if gameID == nil
          _event << "That game is not currently being tracked"
          next
        end

        begin

          PostgresDB::Conn.transaction do |conn|

            # Delete the tracked game row
            conn.exec("DELETE from public.tracked_games where game_id = '#{gameID}'")

            # Go through all of the runners and delete the tracked game
            runners = PostgresDB.getCurrentRunners
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
            PostgresDB.updateCurrentRunners(runners)

            # Delete the game and category aliases
            conn.exec("DELETE from public.aliases where alias LIKE '#{_gameAlias}%'")

            # Delete the game's resources
            conn.exec("DELETE from public.resources where game_alias = '#{_gameAlias}'")
          end # end of transaction

        rescue Exception => e
          _event << "Error while deleteing the game #{e.backtrace} #{e.message}"
          next
        end # end of begin

        _event << "Game removed successfully"

      end # end of command body

    end
  end
end
