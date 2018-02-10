module RunTracker
  module CommandLoader
    module ListGames
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:listgames, description: 'Lists all tracked games.',
                          usage: '~listgames',
                          permission_level: PERM_USER,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 0,
                          max_args: 0) do |_event|

        # Command Body
        aliases = SQLiteDB::Conn.execute('SELECT * FROM "aliases" WHERE type="game"')
        results = SQLiteDB::Conn.execute('SELECT * FROM "tracked_games"')

        embed = Discordrb::Webhooks::Embed.new(
            title: "Tracked Games",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#1AB5FF"
        results.each do |game|
          gameAlias = ''
          aliases.each do |row|
            if row['id'] == game['game_id']
              gameAlias = row['alias']
            end
          end
          channel = JSON.parse(Discordrb::API::Channel.resolve(RTBot.token, game['announce_channel']))
          embed.add_field(
            name: game['game_name'],
            value: "_Alias_ : `#{gameAlias}`\n_Announce Channel_ : #{channel['name']}",
            inline: true
          )
        end
        RTBot.send_message(_event.channel.id, "", false, embed)

      end # end of command body
    end # end of module
  end
end
