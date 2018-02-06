module RunTracker
  module CommandLoader
    module SetGameAlias
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:setgamealias, description: '',
                         usage: "~setgamealias <old alias> <new alias>\nAlias must be unique.",
                         permission_level: PERM_MOD,
                         rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                         bucket: :limiter,
                         min_args: 2,
                         max_args: 2) do |_event, _oldAlias, _newAlias|

        # check if the newly provided alias is valid
        if !/[^a-zA-Z0-9\-()&:%]./.match(_newAlias).nil?
          return "`~setgamealias <old alias> <new alias>`\nAlias must be unique."
        end

        # TODO fix

        SQLiteDB::Conn.transaction do |conn|

          # Check to see if alias even exists
          conn.prepare("find_alias", "SELECT * FROM \"aliases\" WHERE alias= $1 and type='game'")
          aliasResults = conn.exec_prepared('find_alias', [_oldAlias])
          pp aliasResults
          if aliasResults.length < 1
            return "Game Alias not found use `!listgames` to see the current aliases"
          end
          conn.execute('DEALLOCATE find_alias')

          # Set the alias for the game, and then change the prefix for any category aliases
          # NOTE sometimes commands hang here forever because too many DB connections
          conn.prepare("update_game_alias", "update aliases set alias=$1 where alias=$2 and type = 'game'")
          conn.exec_prepared('update_game_alias', [_newAlias, _oldAlias])
          conn.execute('DEALLOCATE update_game_alias')

          categoryAliases = conn.execute("SELECT * FROM aliases WHERE type='category'")
          conn.prepare("update_category_prefix", "update aliases set alias = $1 where alias = $2 and type = 'category'")
          categoryAliases.each do |catAlias|
            prefix = catAlias['alias'].split('-').first
            withPrefixRemoved = catAlias['alias'].split('-')
            withPrefixRemoved[0] = "#{_newAlias}-"
            newCategoryAlias = withPrefixRemoved.join('')
            if prefix.casecmp(_oldAlias).zero?
              conn.exec_prepared('update_category_prefix', ["#{newCategoryAlias}", catAlias['alias']])
            end
          end
          conn.execute('DEALLOCATE update_category_prefix')

          # Set the alias for any existing resources
          conn.prepare('update_resource_aliases', "update resources set game_alias=$1 where game_alias=$2")
          conn.exec_prepared('update_resource_aliases', [_newAlias, _oldAlias])
          conn.execute('DEALLOCATE update_resource_aliases')

        end

        _event << "Alias updated from #{_oldAlias} to #{_newAlias}"

        return
      end # end command body
    end # end SetGameAlias module
  end
end
