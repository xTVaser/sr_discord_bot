module RunTracker
  module CommandLoader
    module ListResources
      extend Discordrb::Commands::CommandContainer

      command(:listresources, description: 'Lists all resources for a specific tracked game.',
                          usage: '!listresources <gameAlias>',
                          min_args: 1,
                          max_args: 1) do |_event, _gameAlias|

        # Command Body
        PostgresDB::Conn.prepare('get_resources', "SELECT * FROM public.resources WHERE game_alias=$1")
        resources = PostgresDB::Conn.exec_prepared('get_resources', [_gameAlias])
        PostgresDB::Conn.exec('DEALLOCATE get_resources')

        message = Array.new
        message.push("Resources for `#{_gameAlias}`:")

        resources.each do |resource|
          message.push("  - #{resource['resource']}")
        end

        message.push("Use !viewresource <gameAlias> <name> to view content")

        _event << Util.arrayToCodeBlock(message)

      end # end of command body
    end # end of module
  end
end
