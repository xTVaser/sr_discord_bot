module RunTracker
  module CommandLoader
    module SetAnnounce
      extend Discordrb::Commands::CommandContainer

      command(:setannounce, description: 'Allows the changing of what channel new runs should be announced on for a game',
                         usage: "!setannounce <gameAlias> <#channel>",
                         permission_level: PERM_MOD,
                         min_args: 2,
                         max_args: 2) do |_event, _gameAlias, _channel|

        channelID = Integer(_channel[2..-2])

        # TODO no error checking, should check to see if this ID is in the servers list
        gameID = PostgresDB.findID(_gameAlias)
        if gameID == nil
          _event << "Game not found with that alias"
          next
        end
        PostgresDB::Conn.prepare('update_announce_channel', 'UPDATE public.tracked_games SET announce_channel = $1 WHERE game_id = $2')
        PostgresDB::Conn.exec_prepared('update_announce_channel', [channelID, gameID])
        PostgresDB::Conn.exec('DEALLOCATE update_announce_channel')

        _event << "Channel updated successfully for #{_gameAlias}"
        
      end # end command body
    end # end SetGameAlias module
  end
end
