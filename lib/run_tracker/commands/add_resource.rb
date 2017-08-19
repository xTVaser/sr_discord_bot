module RunTracker
  module CommandLoader
    module AddResource
      extend Discordrb::Commands::CommandContainer

      command(:addresource, description: 'Lists all categories for a specific tracked game.',
                          usage: '!addresource <gameAlias> <resource name> <content>',
                          min_args: 3,
                          max_args: 3) do |_event, _gameAlias, _name, _content|

        # Command Body
        # Check to see if alias even exists
        PostgresDB::Conn.prepare("find_alias", "SELECT * FROM public.\"aliases\" WHERE alias= $1 and type='game'")
        aliasResults = PostgresDB::Conn.exec_prepared('find_alias', [_gameAlias])
        if aliasResults.ntuples < 1
          _event << "Game Alias not found use !listgames to see the current aliases"
          PostgresDB::Conn.exec('DEALLOCATE find_alias')
          return
        end
        PostgresDB::Conn.exec('DEALLOCATE find_alias')

        begin
          # Set the alias for the game, and then change the prefix for any category aliases
          PostgresDB::Conn.prepare('add_game_resource', 'insert into public.resources
            ("resource", "game_alias", "content")
            values ($1, $2, $3)')
          PostgresDB::Conn.exec_prepared('add_game_resource', [_name, _gameAlias, _content])
          PostgresDB::Conn.exec('DEALLOCATE add_game_resource')
        rescue PG::UniqueViolation
          _event << "Already a resource for that game defined with the name `#{_name}`"
          PostgresDB::Conn.exec('DEALLOCATE add_game_resource')
          return
        end

        _event << "Resource added."

      end # end of command body
    end # end of module
  end
end
