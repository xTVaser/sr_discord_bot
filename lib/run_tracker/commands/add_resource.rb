module RunTracker
  module CommandLoader
    module AddResource
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:addresource, description: 'Lists all categories for a specific tracked game.',
                          usage: '~addresource <gameAlias> <resource name> <content>',
                          permission_level: PERM_MOD,
                          min_args: 3,
                          max_args: 3,
                          bucket: :limiter) do |_event, _gameAlias, _name, _content|

        # Command Body
        # Check to see if alias even exists
        # TODO fix this command
        SQLiteDB::Conn.prepare("find_alias", "SELECT * FROM \"aliases\" WHERE alias= $1 and type='game'")
        aliasResults = SQLiteDB::Conn.exec_prepared('find_alias', [_gameAlias])
        if aliasResults.length < 1
          _event << "Game Alias not found use ~listgames to see the current aliases"
          SQLiteDB::Conn.execute('DEALLOCATE find_alias')
          return
        end
        SQLiteDB::Conn.execute('DEALLOCATE find_alias')

        begin
          # Set the alias for the game, and then change the prefix for any category aliases
          SQLiteDB::Conn.prepare('add_game_resource', 'insert into resources
            ("resource", "game_alias", "content")
            values ($1, $2, $3)')
          SQLiteDB::Conn.exec_prepared('add_game_resource', [_name, _gameAlias, _content])
          SQLiteDB::Conn.execute('DEALLOCATE add_game_resource')
        rescue PG::UniqueViolation
          _event << "Already a resource for that game defined with the name `#{_name}`"
          SQLiteDB::Conn.execute('DEALLOCATE add_game_resource')
          return
        end

        _event << "Resource added."

      end # end of command body
    end # end of module
  end
end
