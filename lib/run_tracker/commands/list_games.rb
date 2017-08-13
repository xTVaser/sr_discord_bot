module RunTracker
  module CommandLoader
    module ListGames
      extend Discordrb::Commands::CommandContainer

      command(:listgames, description: 'Lists all tracked games.',
                          usage: '!listgames',
                          min_args: 0,
                          max_args: 0) do |_event|

        # Command Body
        results = PostgresDB::Conn.exec('SELECT * FROM public."tracked_games"')
        RTBot.send_message(DevChannelID, "`#{results.ntuples}` Currently Tracked Game(s):")

        count = 1
        results.each do |game|
          return RTBot.send_message(DevChannelID, "[#{count}] #{game['game_name']} - ID: `#{game['game_id']}`  " \
                                                  "Alias: `#{game['game_alias']}`  Announce Channel: `#{game['announce_channel']}`")
          count += 1
        end
      end # end of command body
    end # end of module
  end
end
