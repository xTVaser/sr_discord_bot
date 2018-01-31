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
        aliases = SQLiteDB::Conn.execute("SELECT * FROM \"aliases\" WHERE type='game'")
        results = SQLiteDB::Conn.execute('SELECT * FROM "tracked_games"')

        message = Array.new
        message.push("<#{results.length}> Currently Tracked Game(s):")
        results.each do |game|
          gameAlias = ''
          aliases.each do |row|
            if row['id'] == game['game_id']
              gameAlias = row['alias']
            end
          end
          channel = JSON.parse(Discordrb::API::Channel.resolve(RTBot.token, game['announce_channel'])) # NOTE not sure if this is the easiest way
          message.push("<Alias: #{gameAlias}> | <Name: #{game['game_name']}> | <Announce_Channel: #{channel['name']}>")
        end

        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end of command body
    end # end of module
  end
end
