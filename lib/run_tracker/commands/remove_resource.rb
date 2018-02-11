module RunTracker
  module CommandLoader
    module RemoveResource
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:removeresource, description: 'Removed a particular games resource',
                          usage: '~removeresource <gameAlias> <resourceName>',
                          permission_level: PERM_MOD,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 2,
                          max_args: 2) do |_event, _gameAlias, _name|

        # Command Body
        begin
          # Set the alias for the game, and then change the prefix for any category aliases
          SQLiteDB::Conn.execute('DELETE FROM resources WHERE game_alias=? and resource=?', _gameAlias, _name)
        rescue Exception => ex
          _event << "No resource for #{_gameAlias} with name #{_name}"
          return
        end

        embed = Discordrb::Webhooks::Embed.new(
            title: "#{_name} Removed From #{_gameAlias} if it Existed",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#ff0000"
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end of command body
    end # end of module
  end
end
