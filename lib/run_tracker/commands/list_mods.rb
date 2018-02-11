module RunTracker
  module CommandLoader
    module ListMods
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:listmods, description: 'Lists all mods for a specific game.',
                          usage: '~listmods <gameAlias>',
                          permission_level: PERM_USER,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 1,
                          max_args: 1) do |_event, _gameAlias|

        # Command Body
        begin
          # Check to see if alias even exists
          aliasResults = SQLiteDB::Conn.execute('SELECT * FROM "aliases" WHERE alias=? and type="game"', _gameAlias)
          if aliasResults.length < 1
            return "Game Alias not found use `~listgames` to see the current aliases"
          end

          game = SQLiteDB.getTrackedGame(aliasResults.first['id'])
          embed = Discordrb::Webhooks::Embed.new(
            title: "Moderators for #{game.name}",
            footer: {
              text: "~help to view a list of available commands"
            }
          )
          embed.colour = "#1AB5FF"
          modList = game.moderators
          # Sort moderators by their date first, and then there amount of verified runs second
          # TODO: this sort will fail if the last_verified_run_date is still null, should start the date at something else maybe epoch
          modList = modList.sort_by { |k, o| [-o.last_verified_run_date.jd, -o.total_verified_runs] }
          modList.each do |key, mod|
            embed.add_field(
              name: mod.src_name,
              value: "_Total Verified Runs_ : #{mod.total_verified_runs}\n_Last Verified Run Date_ : #{mod.last_verified_run_date}",
              inline: true
            )
          end
        rescue SQLite3::Exception => e
          puts "error message please log me"
        end
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end of command body
    end # end of module
  end
end
