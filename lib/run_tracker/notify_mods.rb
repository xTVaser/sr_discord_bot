module RunTracker
  module NotifyMods

    def self.notifyMods

      # Loop through all of the tracked games
      trackedGames = SQLiteDB.getTrackedGames
      if trackedGames == nil
        return
      end
      # TODO: this does not handle adding new moderators
      trackedGames.each do |trackedGame|
        # Get any unverified runs for this game
        requestLink = "#{SrcAPI::API_URL}runs" \
                      "?game=#{trackedGame.id}" \
                      '&status=new&orderby=date&direction=asc'

        results = Util.jsonRequest(requestLink)['data']

        message = Array.new
        message.push("#{trackedGame.name}'s unverified runs that you have not already been notified of")
        runIDs = Array.new
        # Construct the message
        results.each do |run|
          # Check to see if we have already notified the mod about this run before
          check = SQLiteDB::Conn.execute("SELECT * FROM notifications WHERE run_id = '#{run['id']}'")
          if check.length > 0
            next
          end
          # Else, add the run to the message
          message.push("#{run['weblink']}")
          runIDs.push(run['id'])
        end
        # If we actually added a single run, notify the mods
        actuallyNotified = false
        if message.length > 1
          trackedGame.moderators.each do |key, moderator|
            if moderator.should_notify == 1 && moderator.discord_id != 0 && moderator.past_moderator == 0
              actuallyNotified = true
              message.push("If you want to stop receiving these notifications reply with #{PREFIX}optout #{moderator.src_name}")
              RTBot.user(moderator.discord_id).pm(Util.arrayToMessage(message))
              message.pop # delete the mod specific line add it back later
            end
          end
          # Add this run's id to the notification table
          runIDs.each do |runID|
            if actuallyNotified == true
              SQLiteDB::Conn.execute("INSERT INTO notifications (run_id) VALUES ('#{runID}')")
            end
          end
        end
      end # end of tracked games loop


    end # end notify mods

  end
end
