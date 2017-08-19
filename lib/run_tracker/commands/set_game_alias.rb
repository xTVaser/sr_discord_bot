module RunTracker
  module CommandLoader
    module SetGameAlias
      extend Discordrb::Commands::CommandContainer

      command(:setgamealias, description: '',
                         usage: "!setgamealias <old alias> <new alias>\nAlias must be unique.",
                         min_args: 2,
                         max_args: 2) do |_event, _oldAlias, _newAlias|

        # check if the newly provided alias is valid
        if !/[^a-zA-Z0-9\-()&:%]./.match(_newAlias).nil?
          return :usage
        end

        PostgresDB::Conn.transaction do |conn|

          # Check to see if alias even exists
          conn.prepare("find_alias", "SELECT * FROM public.\"aliases\" WHERE alias= $1 and type='game'")
          aliasResults = conn.exec_prepared('find_alias', _oldAlias)
          if aliasResults.ntuples < 1
            return "Game Alias not found use !listgames to see the current aliases"
          end
          conn.exec('DEALLOCATE find_alias')

          # Set the alias for the game, and then change the prefix for any category aliases
          conn.prepare("update_game_alias", "update public.aliases set alias=$1 where alias=$2 and type = 'game'")
          conn.exec_prepared('update_game_alias', [_newAlias, _oldAlias])
          conn.exec('DEALLOCATE update_game_alias')

          categoryAliases = conn.exec("SELECT * FROM public.aliases WHERE type='category'")
          conn.prepare("update_category_prefix", "update public.aliases set alias = $1 where alias = $2 and type = 'category'")
          categoryAliases.each do |catAlias|
            prefix = catAlias['alias'].split('-').first
            withPrefixRemoved = catAlias['alias'].split('-')
            withPrefixRemoved[0] = "#{_newAlias}-"
            newCategoryAlias = withPrefixRemoved.join('')
            if prefix.casecmp(_oldAlias).zero?
              conn.exec_prepared('update_category_prefix', ["#{newCategoryAlias}", catAlias['alias']])
            end
          end
          conn.exec('DEALLOCATE update_category_prefix')

        end
        # TODO add some output for errors

        return
      end # end command body
    end # end SetGameAlias module
  end
end
