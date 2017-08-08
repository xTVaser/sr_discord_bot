module RunTracker
  module CommandLoader
    module RemoveGame
      extend Discordrb::Commands::CommandContainer

      command(:removegame, description: "Removes a game from the list of tracked games.",
                           usage: "!removegame <id/name> <game-id/game-name>",
                           permission_level: 3, # NOTE hardcoded
                           min_args: 1,
                           max_args: 1) do |event, type, search_field|

        if type.casecmp('name').zero?
          removeGameByName(event, search_field)
        elsif type.casecmp('id').zero?
          removeGameById(event, search_field)
        end

        def removeGameByName(event, name)
          begin
            # Select the row we wish to delete
            PostgresDB::Conn.prepare('statement1', 'select * from public."tracked_games" where "game_name" = $1')
            row = PostgresDB::Conn.exec_prepared('statement1', [name])

            if row.empty? # No games found with entered name.
              event << 'No games found under this name.'
            elsif row > 1 # More than one game was found under this name
              event << 'More than one game found under this name. Did you mean: '
              event << 'game name 1: id'
              event << 'game name 2: id'
              event << 'Remove this game by using the command again with the proper ID.'
            else # Only one game was found and can be deleted
              PostgresDB::Conn.prepare('statement2', 'delete * from public."tracked_games" where "game_name = $1"')
              PostgresDB::Conn.exec_prepared('statement2', [name])
            end
          rescue
            event << e.backtrace + e.message # TODO: Replace backtrace with an actual error message.
          end
        end

        def removeGameById(event, id)
          begin
            PostgresDB::Conn.prepare('statement1', 'select * from public."tracked_games" where "game_id" = $1')
            row = PostgresDB::Conn.exec_prepared('statement1', [id])

            if row.empty? # If no ID's were found with entered ID.
              event << 'No games found with this ID.'
            else # Else remove game. ID is PK so it is garunteed to be unique.
              PostgresDB::Conn.prepare('statement2', 'delete * from public."tracked_games" where "game_id" = $1')
              PostgresDB::Conn.exec_prepared('statement2', [id])
            end
          rescue
            event<< e.backtrace + e.message
          end
        end

      end
    end
  end
end
