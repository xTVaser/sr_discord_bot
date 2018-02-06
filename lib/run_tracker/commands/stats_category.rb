module RunTracker
  module CommandLoader
    module StatsCategory
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:statscategory, description: 'Displays stats for a given tracked games category',
                        usage: "~statscategory <alias>",
                        permission_level: PERM_USER,
                        rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                        bucket: :limiter,
                        min_args: 1,
                        max_args: 1) do |_event, _categoryAlias|

        # Command Body

        gameID = SQLiteDB.categoryAliasToGameID(_categoryAlias)
        if gameID == nil
          _event << "No category found with that alias, use ~listcategories <gameAlias> to view current aliases"
          next
        end
        categoryID = SQLiteDB.findID(_categoryAlias)

        # First verify if that game is even tracked (by getting it)
        game = SQLiteDB.getTrackedGame(gameID)

        # Find the category
        category = nil
        game.categories.each do |key, cat|
          if key.casecmp(categoryID).zero?
            category = cat
          end
        end
        if category == nil
          puts "[ERROR] Something went wrong stats category command finding category"
          _event << "No category found with that alias, use !listcategories <gameAlias> to view current aliases"
          next
        end

        # else, we can do things with it.
        message = Array.new

        # Name
        message.push(">Category Summary for - #{category.category_name} for game: #{game.name}:\n")

        pp category

        # Current WR
        runInfo = SrcAPI.getRunInfo(category.current_wr_run_id)
        message.push("Current WR")
        message.push("============")
        message.push("<Runner #{runInfo['name']}> <Time #{Util.secondsToTime(category.current_wr_time)}>")
        dateDiff = (Date.today).jd - runInfo['date'].jd
        message.push("<Date #{runInfo['date'].to_s}> <#{dateDiff}> days ago")
        message.push("[Speedrun.com Link](#{runInfo['srcLink']})")
        message.push("[Video Link](#{runInfo['videoLink']})\n")

        # Longest Held WR
        message.push("Longest Held WR")
        message.push("============")
        if category.longest_held_wr_id == ""
          runInfo = SrcAPI.getRunInfo(category.current_wr_run_id) # no one has broken the record yet
          message.push("<Runner #{runInfo['name']}> <Time #{runInfo['time']}> < Still Counting >")
        else
          runInfo = SrcAPI.getRunInfo(category.longest_held_wr_id)
          message.push("<Runner #{runInfo['name']}> <Time #{runInfo['time']}> <Lasting #{category.longest_held_wr_time} days>")
        end
        dateDiff = (Date.today).jd - runInfo['date'].jd
        message.push("<Date #{runInfo['date'].to_s}> <#{dateDiff}> days ago")
        message.push("[Speedrun.com Link](#{runInfo['srcLink']})")
        message.push("[Video Link](#{runInfo['videoLink']})\n")

        # Number of submitted WRs
        # Number of submitted runs
        message.push(">Number of Submitted World Records: <#{category.number_submitted_wrs}>")
        message.push(">Number of Submitted Runs: <#{category.number_submitted_runs}>")

        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end of command body
    end
  end
end
