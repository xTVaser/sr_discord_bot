module RunTracker
  module CommandLoader
    module Resource
      extend Discordrb::Commands::CommandContainer

      command(:resource, description: 'Displays the content of a particular games resource',
                         usage: '!resource <gameAlias> <name>',
                         permission_level: PERM_USER,
                         min_args: 2,
                         max_args: 2) do |_event, _gameAlias, _name|

        # Command Body
        PostgresDB::Conn.prepare('get_resource', "SELECT * FROM public.resources WHERE game_alias=$1 and resource=$2")
        resource = PostgresDB::Conn.exec_prepared('get_resource', [_gameAlias, _name])
        PostgresDB::Conn.exec('DEALLOCATE get_resource')

        if resource.ntuples < 1
          _event << "No resource found for that game with that name!"
          return
        end

        resource = resource.first
        _event << resource['content']

      end # end of command body
    end # end of module
  end
end
