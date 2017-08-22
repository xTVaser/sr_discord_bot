module RunTracker
  module CommandLoader
    module RemoveGame
      extend Discordrb::Commands::CommandContainer

      command(:removegame, description: 'Removes a game from the list of tracked games.',
                           usage: '!removegame <game-alias>',
                           permission_level: PERM_ADMIN,
                           min_args: 1,
                           max_args: 1) do |event, search_field|

        "yes"
        # if search_field.empty?
        #   #event << '`game-alias` field is empty. Please enter a game alias to remove said game.'
        # else
        #   #removeGameById(event, search_field)
        # end
      end # end of command body

      def self.removeGameById(event, name)
        begin
          PostgresDB::Conn.prepare('statement1', 'select "game_id" from public."tracked_games" where "game_alias" = $1')
          id = PostgresDB::Conn.exec_prepared('statement1', [name])

          if id.empty? # If no ID's were found with entered ID.
            event << 'No games found with this ID.'
          else # Else remove game. ID is PK so it is guaranteed to be unique.
            PostgresDB::Conn.prepare('statement2', 'delete * from public."tracked_games" where "game_id" = $1')
            PostgresDB::Conn.exec_prepared('statement2', [id])
          end
        rescue Exception => e
           RTBot.send_message(DevChannelID, e.backtrace.inspect + e.message)
        end
      end
    end
  end
end
