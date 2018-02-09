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
        aliasResults = SQLiteDB::Conn.execute('SELECT * FROM "aliases" WHERE alias="?" and type="category"', _oldAlias)
        if aliasResults.length < 1
          return "Category Alias not found use `~listcategories <game_alias>` to see the current aliases"
        end

        gameAlias = _oldAlias.split('-').first

        begin
          # Set the alias for the game, and then change the prefix for any category aliases
          SQLiteDB::Conn.execute('update aliases set alias = ? where alias = ? and type = "category"', 
                                  "#{gameAlias}-#{_newAlias}", _oldAlias)
        rescue SQLite3::Exception => e
          puts "oh no fix me"
        end
        
        return
      end # end command body
    end # end SetGameAlias module
  end
end
