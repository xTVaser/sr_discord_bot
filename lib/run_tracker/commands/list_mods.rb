module RunTracker
  module CommandLoader
    module ListMods
      extend Discordrb::Commands::CommandContainer

      command(:listmods, description: 'Lists all mods for a specific game.',
                          usage: '!listmods <gameAlias>',
                          min_args: 1,
                          max_args: 1) do |_event, _gameAlias|

        # Command Body

        modListing = []
        PostgresDB::Conn.transaction do |conn|

          # Check to see if alias even exists
          conn.prepare("find_alias", "SELECT * FROM public.\"aliases\" WHERE alias=$1 and type='game'")
          aliasResults = conn.exec_prepared('find_alias', [_gameAlias])
          if aliasResults.ntuples < 1
            return "Game Alias not found use !listgames to see the current aliases"
          end
          conn.exec('DEALLOCATE find_alias')



          game = PostgresDB.getTrackedGame(aliasResults.first['id'])
          modListing.push("Moderators for #{game.name}:\n")
          modList = game.moderators

          # Sort moderators by their date first, and then there amount of verified runs second
          # TODO this sort will fail if the last_verified_run_date is still null, should start the date at something else maybe epoch
          modList = modList.sort_by { |k, o| [-o.last_verified_run_date.jd, -o.total_verified_runs] }

          modList.each do |key, mod|
            modListing.push("#{mod.src_name} | #{mod.total_verified_runs} | #{mod.last_verified_run_date}")
          end
        end

        # TODO add error messages

        _event << Util.arrayToCodeBlock(modListing)

      end # end of command body
    end # end of module
  end
end
