module RunTracker
  module CommandLoader
    module ListCategories
      extend Discordrb::Commands::CommandContainer

      command(:listcategories, description: 'Lists all categories for a specific tracked game.',
                          usage: '!listcategories',
                          min_args: 1,
                          max_args: 1) do |_event, _game_alias|

        # Command Body
        gameID = PostgresDB.findID(_game_alias)
        trackedGame = PostgresDB.getTrackedGame(gameID)
        aliases = PostgresDB::Conn.exec("SELECT * FROM public.\"aliases\" WHERE type='category'")

        _event << "Categories for `#{_game_alias}`:"

        messages = Array.new
        trackedGame.categories.each do |categoryID, categoryData|
          categoryAlias = ''
          aliases.each do |row|
            pp row
            if row['id'].casecmp(categoryID).zero?
              categoryAlias = row['alias']
            end
          end
          messages.push("Alias: #{categoryAlias} | Name: #{categoryData.category_name} | Current WR: #{categoryData.current_wr_time}")
        end

        _event << Util.arrayToCodeBlock(messages)

      end # end of command body
    end # end of module
  end
end
