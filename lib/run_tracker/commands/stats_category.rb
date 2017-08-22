module RunTracker
  module CommandLoader
    module StatsCategory
      extend Discordrb::Commands::CommandContainer

      command(:statscategory, description: 'Displays stats for a given tracked games category',
                        usage: "!statscategory <alias>",
                        min_args: 1,
                        max_args: 1) do |_event, _categoryAlias|

        # Command Body

        gameID = PostgresDB.categoryAliasToGameID(_categoryAlias)
        if gameID == nil
          _event << "No category found with that alias, use !listcategories <gameAlias> to view current aliases"
          next
        end
        categoryID = PostgresDB.findID(_categoryAlias)

        # First verify if that game is even tracked (by getting it)
        game = PostgresDB.getTrackedGame(gameID)

        # Find the category
        category = nil
        game.categories.each do |key, cat|
          if key.casecmp(categoryID).zero?
            category = cat
          end
        end
        if category == nil
          _event << "Something went wrong, shouldnt have happend but that category wasnt found"
        end

        # else, we can do things with it.
        message = Array.new

        # Name
        message.push("Category Summary for: #{category.category_name} for game: #{game.name}:\n")

        # Current WR
        runInfo = SrcAPI.getRunInfo(category.current_wr_run_id)
        message.push("The current WR is: #{Util.secondsToTime(category.current_wr_time)} by #{runInfo['name']} - #{runInfo['srcLink']}, Video Link - #{runInfo['videoLink']}.")

        # Longest Held WR
        runInfo = SrcAPI.getRunInfo(category.longest_held_wr_id)
        message.push("The longest held WR is/was a: #{runInfo['time']} by #{runInfo['name']} lasting #{category.longest_held_wr_time} days. - #{runInfo['srcLink']}, Video Link - #{runInfo['videoLink']}")

        # Number of submitted WRs
        # Number of submitted runs
        message.push("Number of Submitted World Records: #{category.number_submitted_wrs}")
        message.push("Number of Submitted Runs: #{category.number_submitted_runs}")

        _event << Util.arrayToCodeBlock(message)

      end # end of command body
    end
  end
end
