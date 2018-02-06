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
        modListing = []
        SQLiteDB::Conn.transaction do |conn|

          # Check to see if alias even exists
          # TODO fix this
          conn.prepare("find_alias", "SELECT * FROM \"aliases\" WHERE alias=$1 and type='game'")
          aliasResults = conn.exec_prepared('find_alias', [_gameAlias])
          if aliasResults.length < 1
            return "Game Alias not found use `~listgames` to see the current aliases"
          end
          conn.execute('DEALLOCATE find_alias')

          game = SQLiteDB.getTrackedGame(aliasResults.first['id'])
          modListing.push("Moderators for #{game.name}:")
          modListing.push("============")
          modList = game.moderators

          # Sort moderators by their date first, and then there amount of verified runs second
          # TODO this sort will fail if the last_verified_run_date is still null, should start the date at something else maybe epoch
          modList = modList.sort_by { |k, o| [-o.last_verified_run_date.jd, -o.total_verified_runs] }

          modList.each do |key, mod|
            modListing.push("<Name #{mod.src_name}> | <Total_Verified_Runs #{mod.total_verified_runs}> | <Last_Verified_Run_Date #{mod.last_verified_run_date}>")
          end
        end

        # TODO add error messages

        _event << Util.arrayToCodeBlock(modListing, highlighting: 'md')

      end # end of command body
    end # end of module
  end
end
