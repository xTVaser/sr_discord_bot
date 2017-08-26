module RunTracker
  module CommandLoader
    module OptIn
      extend Discordrb::Commands::CommandContainer

      command(:optin, description: 'Allows a speedrun.com leaderboard mod to opt-in to receiving notifications from the games they moderate',
                         usage: '!optin <speedrunComName> *must be the user themselves',
                         permission_level: PERM_MOD,
                         min_args: 1,
                         max_args: 1) do |_event, _srcName|

        # Command Body

        # First check to see if the moderator exists for one of the games
        mod = nil
        trackedGames = PostgresDB.getTrackedGames
        trackedGames.each do |trackedGame|
          trackedGame.moderators.each do |key, moderator|
            if moderator.src_name.downcase.casecmp(_srcName.downcase).zero?
              mod = moderator
              break
            end
          end
        end

        if mod == nil
          _event << "No moderator for any of the currently tracked games by the name #{_srcName}"
          next
        end

        # Otherwise, let's check to see if the moderator has already opted in
        if mod.should_notify == true
          _event << "#{_srcName} has already opted in, !optout #{_srcName} to opt-out"
          next
        end

        # Otherwise, we are good to opt the moderator in
        mod.discord_id = _event.message.user.id
        mod.should_notify = true

        # Update all relevant games
        trackedGames = PostgresDB.getTrackedGames
        trackedGames.each do |trackedGame|
          trackedGame.moderators.each do |key, moderator|
            if moderator.src_name.downcase.casecmp(_srcName.downcase).zero?
              trackedGame.moderators[key] = mod
              PostgresDB.updateTrackedGame(trackedGame)
              break
            end
          end
        end

        _event << "#{_srcName} moderator successfully opted-in, use !optout #{_srcName} to opt-out at any time."

      end # end of command body
    end # end of module
  end
end