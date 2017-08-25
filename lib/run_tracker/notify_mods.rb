module RunTracker
  module NotifyMods

    def self.notifyMods

      # Loop through all of the tracked games
      trackedGames = PostgresDB.getTrackedGames
      trackedGames.each do |trackedGame|
        # Get any unverified runs for this game
        requestLink = "#{SrcAPI::API_URL}runs" \
                      "?game=#{trackedGame.id}" \
                      '&status=new&orderby=date&direction=asc&max=200'

        results = Util.jsonRequest(requestLink)['data']

        trackedGame.moderators.each do |key, moderator|
          if moderator.should_notify == true && moderator.discord_id != 0
            message = Array.new
            message.push("#{trackedGame.name}'s unverified runs that you have not already been notified of")
            results.each do |run|
              pp run
              message.push("#{run['weblink']}")
            end
            message.push("If you want to stop receiving these notifications reply with !optout #{moderator.src_name}")
            RTBot.user(moderator.discord_id).pm(Util.arrayToMessage(message))
          end
        end
      end


    end # end notify mods

  end
end
