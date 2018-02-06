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
        SQLiteDB::Conn.prepare('update_announce_channel', 'UPDATE tracked_games SET announce_channel = $1 WHERE game_id = $2')
        SQLiteDB::Conn.exec_prepared('update_announce_channel', [channelID, gameID])
        SQLiteDB::Conn.execute('DEALLOCATE update_announce_channel')

        _event << "Channel updated successfully for #{_gameAlias}"

      end # end command body
    end # end SetGameAlias module
  end
end
