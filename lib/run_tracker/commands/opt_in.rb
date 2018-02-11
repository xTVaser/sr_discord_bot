module RunTracker
  module CommandLoader
    module OptIn
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:optin, description: 'Allows a speedrun.com leaderboard mod to opt-in to receiving notifications from the games they moderate',
                         usage: "#{PREFIX}optin <speedrunComName> *must be the user themselves",
                         permission_level: PERM_MOD,
                         rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                         bucket: :limiter,
                         min_args: 1,
                         max_args: 1) do |_event, _srcName|

        # Command Body
        # TODO: this command wipes the moderators stats
        # TODO: what does ^ mean

        # First check to see if the moderator exists for one of the games
        mod = nil
        moderatorResults = SQLiteDB::Conn('SELECT * FROM moderators WHERE "src_name"=?', _srcName.downcase)
        mod = moderatorResults.first

        if mod == nil
          _event << "No moderator for any of the currently tracked games by the name `#{_srcName}`"
          next
        end

        # Otherwise, let's check to see if the moderator has already opted in
        if mod['should_notify'] == true
          _event << "#{_srcName} has already opted in, `#{PREFIX}optout #{_srcName}` to opt-out"
          next
        end

        SQLiteDB::Conn.execute('update moderators
                                set discord_id = ?,
                                    should_notify = ?,
                                where "src_name" = ?',
                                _event.message.user.id,
                                1,
                                _srcName.downcase)
        embed = Discordrb::Webhooks::Embed.new(
            title: "Moderator Successfully Opted-In",
            description: "Use `#{PREFIX}optout #{_srcName}` to opt-out at any time",
            footer: {
              text: "#{PREFIX}help to view a list of available commands"
            }
        )
        embed.colour = "#35f904"
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end of command body
    end # end of module
  end
end
