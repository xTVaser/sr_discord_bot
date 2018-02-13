module RunTracker
  module CommandLoader
    module StatsCategory
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:statscategory, description: 'Displays stats for a given tracked games category',
                        usage: "#{PREFIX}statscategory <alias>",
                        permission_level: PERM_USER,
                        rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                        bucket: :limiter,
                        min_args: 1,
                        max_args: 1) do |_event, _categoryAlias|

        # Command Body

        gameID = SQLiteDB.categoryAliasToGameID(_categoryAlias)
        if gameID == nil
          _event << "No category found with that alias, use #{PREFIX}listcategories <gameAlias> to view current aliases"
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
          Stackdriver.log("Something went wrong stats category command finding category", :ERROR)
          _event << "No category found with that alias, use !listcategories <gameAlias> to view current aliases"
          next
        end

        # else, we can do things with it.
        embed = Discordrb::Webhooks::Embed.new(
            title: "Category Summary for - #{category.category_name} in #{game.name}",
            thumbnail: {
              url: game.cover_url
            },
            footer: {
              text: "#{PREFIX}help to view a list of available commands"
            }
        )
        embed.colour = "#1AB5FF"

        # Name
        message.push(">:\n")

        # Current WR
        runInfo = SrcAPI.getRunInfo(category.current_wr_run_id)
        dateDiff = (Date.today).jd - runInfo['date'].jd
        embed.add_field(
          name: "Current WR",
          value: "_Runner_: #{runInfo['name']}\n_Time_: `#{Util.secondsToTime(category.current_wr_time)}`\n_Date_: #{runInfo['date'].to_s} - #{dateDiff} days ago\n_Speedrun.com Link_:#{runInfo['srcLink']}\n_Video Link_:#{runInfo['videoLink']}",
          inline: false
        )
        embed.colour = "#1AB5FF"
        # Longest Held WR
        runner = ""
        time = ""
        if category.longest_held_wr_id == ""
          runInfo = SrcAPI.getRunInfo(category.current_wr_run_id) # no one has broken the record yet
          runner = runInfo['name']
          time = "#{runInfo['time']}, days Still Counting..."
        else
          runInfo = SrcAPI.getRunInfo(category.longest_held_wr_id)
          runner = runInfo['name']
          time = "#{runInfo['time']}, Lasting #{category.longest_held_wr_time} days"
        end
        dateDiff = (Date.today).jd - runInfo['date'].jd
        embed.add_field(
          name: "Longest Held WR",
          value: "_Runner_: #{runner}\n_Time_: `#{time}`\n_Date_: #{runInfo['date'].to_s} - #{dateDiff} days ago\n_Speedrun.com Link_:#{runInfo['srcLink']}\n_Video Link_:#{runInfo['videoLink']}",
          inline: false
        )
        embed.add_field(
          name: "Number of Submitted World Records",
          value: category.number_submitted_wrs,
          inline: true
        )
        embed.add_field(
          name: "Number of Submitted Runs",
          value: category.number_submitted_runs,
          inline: true
        )
        RTBot.send_message(_event.channel.id, "", false, embed)

      end # end of command body
    end
  end
end
