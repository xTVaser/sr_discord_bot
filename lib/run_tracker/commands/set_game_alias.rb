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

        begin
          SQLiteDB::Conn.transaction
          # Check to see if alias even exists
          aliasResults = SQLiteDB::Conn.execute('SELECT * FROM "aliases" WHERE alias= ? and type="game"', _oldAlias)
          pp aliasResults
          if aliasResults.length < 1
            return "Game Alias not found use `!listgames` to see the current aliases"
          end

          # Set the alias for the game, and then change the prefix for any category aliases
          SQLiteDB::Conn.execute('update aliases set alias=? where alias=? and type = "game"', _newAlias, _oldAlias)

          categoryAliases = SQLiteDB::Conn.execute('SELECT * FROM aliases WHERE type="category"')
          categoryAliases.each do |catAlias|
            prefix = catAlias['alias'].split('-').first
            withPrefixRemoved = catAlias['alias'].split('-')
            withPrefixRemoved[0] = "#{_newAlias}-"
            newCategoryAlias = withPrefixRemoved.join('')
            if prefix.casecmp(_oldAlias).zero?
              SQLiteDB::Conn.execute('update aliases set alias=? where alias=? and type = "category"', 
                                      "#{newCategoryAlias}", catAlias['alias'])
            end
          end

          # Set the alias for any existing resources
          SQLiteDB::Conn.execute('update resources set game_alias=? where game_alias=?', _newAlias, _oldAlias)
          SQLiteDB::Conn.commit
        rescue SQLite3::Exception => e
          SQLiteDB::Conn.rollback
          puts "oh no"
          return "oh no"
        end

        embed = Discordrb::Webhooks::Embed.new(
            title: "Game Alias Updated Successfully",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#35f904"
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end command body
    end # end SetGameAlias module
  end
end
