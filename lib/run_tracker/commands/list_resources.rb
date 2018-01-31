module RunTracker
  module CommandLoader
    module ListResources
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:listresources, description: 'Lists all resources for a specific tracked game.',
                          usage: '~listresources <gameAlias>',
                          permission_level: PERM_USER,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 1,
                          max_args: 1) do |_event, _gameAlias|

        # Command Body
        SQLiteDB::Conn.prepare('get_resources', "SELECT * FROM resources WHERE game_alias=$1")
        resources = SQLiteDB::Conn.exec_prepared('get_resources', [_gameAlias])
        SQLiteDB::Conn.execute('DEALLOCATE get_resources')

        message = Array.new
        message.push("Resources for #{_gameAlias}:")
        message.push("============")

        resources.each do |resource|
          message.push("< #{resource['resource']} >")
        end

        message.push("")
        message.push("Use <~viewresource #{_gameAlias} name> to view content")

        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end of command body
    end # end of module
  end
end
