module RunTracker
  module CommandLoader
    module OptOut
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:optout, description: 'Allows a speedrun.com leaderboard mod to opt-out to stop receiving notifications from the games they moderate',
                         usage: '~optout <speedrunComName> *must be the user themselves',
                         permission_level: PERM_MOD,
                         rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                         bucket: :limiter,
                         min_args: 1,
                         max_args: 1) do |_event, _srcName|

        # Command Body

        # TODO change this because separate table now

        # First check to see if the moderator exists for one of the games
        mod = nil
        moderatorResults = SQLiteDB::Conn('SELECT * FROM moderators WHERE "src_name"=?', _srcName.downcase)
        mod = moderatorResults.first

        if mod == nil
          _event << "No moderator for any of the currently tracked games by the name #{_srcName}"
          next
        end

        if mod.discord_id != _event.message.user.id
          _event << "You are not the discord user that originally opted in, get an admin to wipe the tables."
          next
        end

        # Otherwise, let's check to see if the moderator has already opted in
        if mod['should_notify'] != true
          _event << "#{_srcName} has not opted in, ~optin #{_srcName} to opt-in"
          next
        end

        # Otherwise, we are good to opt the moderator in
        SQLiteDB::Conn.execute('update moderators
                                set discord_id = ?,
                                    should_notify = ?,
                                where "src_name" = ?',
                                _event.message.user.id,
                                0,
                                _srcName.downcase)

        _event << "Moderator successfully opted-out, use ~optin #{_srcName} to opt-back-in at any time."

      end # end of command body
    end # end of module
  end
end
