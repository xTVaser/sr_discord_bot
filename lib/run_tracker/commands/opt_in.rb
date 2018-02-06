module RunTracker
  module CommandLoader
    module OptIn
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:optin, description: 'Allows a speedrun.com leaderboard mod to opt-in to receiving notifications from the games they moderate',
                         usage: '~optin <speedrunComName> *must be the user themselves',
                         permission_level: PERM_MOD,
                         rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                         bucket: :limiter,
                         min_args: 1,
                         max_args: 1) do |_event, _srcName|

        # Command Body
        # TODO this command wipes the moderators stats

        # First check to see if the moderator exists for one of the games
        mod = nil
        trackedGames = SQLiteDB.getTrackedGames
        trackedGames.each do |trackedGame|
          trackedGame.moderators.each do |key, moderator|
            if moderator.src_name.downcase.casecmp(_srcName.downcase).zero?
              mod = moderator
              break
            end
          end
        end

        if mod == nil
          _event << "No moderator for any of the currently tracked games by the name `#{_srcName}`"
          next
        end

        # Otherwise, let's check to see if the moderator has already opted in
        if mod.should_notify == true
          _event << "#{_srcName} has already opted in, `~optout #{_srcName}` to opt-out"
          next
        end

        # Update all relevant games
        trackedGames = SQLiteDB.getTrackedGames
        trackedGames.each do |trackedGame|
          trackedGame.moderators.each do |key, moderator|
            if moderator.src_name.downcase.casecmp(_srcName.downcase).zero?
              # Update each mod's game individually dont corrupt other game's instances
              trackedGame.moderators[key].discord_id = _event.message.user.id
              trackedGame.moderators[key].should_notify = true
              SQLiteDB.updateTrackedGame(trackedGame)
              break
            end
          end
        end

        _event << "Moderator successfully opted-in, use `~optout #{_srcName}` to opt-out at any time."

      end # end of command body
    end # end of module
  end
end
