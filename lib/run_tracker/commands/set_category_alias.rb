module RunTracker
  module CommandLoader
    module SetCategoryAlias
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:setcategoryalias, description: '',
                         usage: "~setcategoryalias <old alias> <new alias>\nAlias must be unique.\nDo not need to enter the game-alias prefix in the new alias.",
                         permission_level: PERM_MOD,
                         rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                         bucket: :limiter,
                         min_args: 2,
                         max_args: 2) do |_event, _oldAlias, _newAlias|

        # check if the newly provided alias is valid
        if !/[^a-zA-Z0-9\-()&:%]./.match(_newAlias).nil?
          return "`~setcategoryalias <old alias> <new alias>`\nAlias must be unique.\nDo not need to enter the game-alias prefix in the new alias."
        end

        # Check to see if alias even exists
        aliasResults = PostgresDB::Conn.exec("SELECT * FROM public.\"aliases\" WHERE alias='#{_oldAlias}' and type='category'")
        if aliasResults.ntuples < 1
          return "Category Alias not found use `~listcategories <game_alias>` to see the current aliases"
        end

        PostgresDB::Conn.transaction do |conn|

          gameAlias = _oldAlias.split('-').first

          # Set the alias for the game, and then change the prefix for any category aliases
          conn.prepare("update_category_alias", "update public.aliases set alias = $1 where alias = $2 and type = 'category'")
          conn.exec_prepared('update_category_alias', ["#{gameAlias}-#{_newAlias}", _oldAlias])
          conn.exec('DEALLOCATE update_category_alias')

        end
        return
      end # end command body
    end # end SetGameAlias module
  end
end
