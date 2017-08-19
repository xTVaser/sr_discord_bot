module RunTracker
  module CommandLoader
    module RemoveResource
      extend Discordrb::Commands::CommandContainer

      command(:removeresource, description: 'Removed a particular games resource',
                          usage: '!removeresource <gameAlias> <resourceName>',
                          min_args: 2,
                          max_args: 2) do |_event, _gameAlias, _name|

        # Command Body
        begin
          # Set the alias for the game, and then change the prefix for any category aliases
          PostgresDB::Conn.prepare('remove_game_resource', 'delete from public.resources WHERE game_alias=$1 and resource=$2')
          PostgresDB::Conn.exec_prepared('remove_game_resource', [_gameAlias, _name])
          PostgresDB::Conn.exec('DEALLOCATE remove_game_resource')
        rescue Exception => ex
          _event << "No resource for #{_gameAlias} with name #{_name}"
          PostgresDB::Conn.exec('DEALLOCATE remove_game_resource')
          return
        end

        _event << "#{_name} removed from #{_gameAlias} if it existed."

      end # end of command body
    end # end of module
  end
end
