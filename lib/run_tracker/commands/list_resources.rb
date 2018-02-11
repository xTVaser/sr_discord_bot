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
        resources = SQLiteDB::Conn.execute('SELECT * FROM resources WHERE game_alias=?', _gameAlias)

        embed = Discordrb::Webhooks::Embed.new(
            title: "Resources for #{_gameAlias}",
            footer: {
              text: "~viewresource #{_gameAlias} <name> to view content\n~help to view a list of available commands"
            }
        )
        embed.colour = "#1AB5FF"
        resources.each do |resource|
          embed.add_field(
            name: resource['resource'],
            inline: true
          )
        end
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end of command body
    end # end of module
  end
end
