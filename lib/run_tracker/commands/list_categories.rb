module RunTracker
  module CommandLoader
    module ListCategories
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:listcategories, description: 'Lists all categories for a specific tracked game.',
                          usage: '~listcategories',
                          permission_level: PERM_USER,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 1,
                          max_args: 1) do |_event, _gameAlias|

        # Command Body
        gameID = SQLiteDB.findID(_gameAlias)
        if gameID == nil
          _event << "No game with that alias, use `~listgames` to view current aliases"
          next
        end
        trackedGame = SQLiteDB.getTrackedGame(gameID)
        aliases = SQLiteDB::Conn.execute('SELECT * FROM "aliases" WHERE type="category"')

        message = Array.new
        message.push("#Categories for #{_gameAlias}, Sorted by Name")
        message.push("[Name](Alias) - <Current WR Time>")
        message.push("============")
        # Sort by name
        trackedGame.categories = trackedGame.categories.sort_by { |k, o| [o.category_name] }
        trackedGame.categories.each do |categoryID, categoryData|
          categoryAlias = ''
          aliases.each do |row|
            if row['id'].casecmp(categoryID).zero?
              categoryAlias = row['alias']
            end
          end
          message.push("[#{categoryData.category_name}](#{categoryAlias}) - <#{Util.secondsToTime(categoryData.current_wr_time)}>")
        end

        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end of command body
    end # end of module
  end
end
