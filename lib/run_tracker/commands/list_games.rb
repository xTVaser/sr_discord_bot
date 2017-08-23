module RunTracker
  module CommandLoader
    module ListGames
      extend Discordrb::Commands::CommandContainer

      command(:listgames, description: 'Lists all tracked games.',
                          usage: '!listgames',
                          permission_level: PERM_USER,
                          min_args: 0,
                          max_args: 0) do |_event|

        # Command Body
        aliases = PostgresDB::Conn.exec("SELECT * FROM public.\"aliases\" WHERE type='game'")
        results = PostgresDB::Conn.exec('SELECT * FROM public."tracked_games"')
        _event << "`#{results.ntuples}` Currently Tracked Game(s):"

        messages = Array.new
        results.each do |game|
          gameAlias = ''
          aliases.each do |row|
            if row['id'] == game['game_id']
              gameAlias = row['alias']
            end
          end
          channel = JSON.parse(Discordrb::API::Channel.resolve(RTBot.token, game['announce_channel'])) # NOTE not sure if this is the easiest way
          messages.push("Alias: #{gameAlias} | Name: #{game['game_name']} | Announce Channel: #{channel['name']}")
        end

        _event << Util.arrayToCodeBlock(messages)

      end # end of command body
    end # end of module
  end
end
