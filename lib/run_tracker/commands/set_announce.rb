module RunTracker
  module CommandLoader
    module SetAnnounce
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:setannounce, description: 'Allows the changing of what channel new runs should be announced on for a game',
                         usage: "~setannounce <gameAlias> <#channel>",
                         permission_level: PERM_MOD,
                         rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                         bucket: :limiter,
                         min_args: 2,
                         max_args: 2) do |_event, _gameAlias, _channel|

        channelID = Integer(_channel[2..-2])

        gameID = SQLiteDB.findID(_gameAlias)
        if gameID == nil
          _event << "Game not found with that alias"
          next
        end
        SQLiteDB::Conn.execute('UPDATE tracked_games SET announce_channel = ? WHERE game_id = ?', channelID, gameID)

        embed = Discordrb::Webhooks::Embed.new(
            title: "Channel Updated Successfully for #{_gameAlias}",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#35f904"
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end command body
    end # end SetGameAlias module
  end
end
