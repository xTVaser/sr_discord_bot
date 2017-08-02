module RunTracker
  module CommandLoader
    module List
      extend Discordrb::Commands::CommandContainer

      command(:list, description: 'Lists various information out',
                     usage: '!list <games/.../...>',
                     min_args: 1,
                     max_args: 1) do |_event, type| # TODO: config

        # Command Body
        if type.casecmp('games').zero?

          results = PostgresDB::Conn.exec('SELECT * FROM public."tracked_games"')
          RTBot.send_message(DevChannelID, "`#{results.ntuples}` Currently Tracked Game(s):")

          count = 1
          results.each do |game|
            return RTBot.send_message(DevChannelID, "[#{count}] #{game['game_name']} - ID: `#{game['game_id']}`  " \
                                                    "Alias: `#{game['game_alias']}`  Announce Channel: `#{game['announce_channel']}`")
            count += 1
          end
        else
          RTBot.send_message(DevChannelID, 'Invalid Syntax: `!list <games/.../...>`')
        end
      end
    end
  end
end
