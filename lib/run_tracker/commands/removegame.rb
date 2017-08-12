module RunTracker
  module CommandLoader
    module RemoveGame
      extend Discordrb::Commands::CommandContainer

      command(:removegame, description: "Removes a game from the list of tracked games.",
                           usage: "!removegame <game-alias>",
                           permission_level: 3, # NOTE hardcoded
                           min_args: 1,
                           max_args: 1) do |event, search_field|

        if search_field.empty?
          event << '`game-alias` field is empty. Please enter a game alias to remove said game.'
        else
          removeGameById(event, search_field)
        end
      end

      def self.removeGameById(event, name)
        begin
          PostgresDB::Conn.prepare('get_game_id', 'select "game_id" from public."tracked_games" where "game_alias" = $1')
          id = PostgresDB::Conn.exec_prepared('get_game_id', [name])

          if id.ntuples != 1 # If no ID's were found with entered ID.
            event << 'No games found with this alias.'
          else # Else remove game. ID is PK so it is guaranteed to be unique.
            PostgresDB::Conn.prepare('delete_game', 'delete * from public."tracked_games" where "game_id" = $1')
            PostgresDB::Conn.exec_prepared('delete_game', [id])

            event << "Game succesfully removed."
          end
        rescue Exception => e
           RTBot.send_message(DevChannelID, e.backtrace.inspect + e.message)
        end
      end

    end
  end
end
