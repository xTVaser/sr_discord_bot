module RunTracker
  module CommandLoader
    module StatsGame
      extend Discordrb::Commands::CommandContainer

      command(:statsgame, description: 'Displays stats for a given tracked game',
                        usage: "!statsgame <alias>",
                        min_args: 1,
                        max_args: 1) do |_event, _gameAlias|

        # Command Body

        gameID = PostgresDB.findID(_gameAlias.downcase)
        if gameID == nil
          _event << "No game found with that alias, use !listgames to view current aliases"
          next
        end
        # First verify if that game is even tracked (by getting it)
        game = PostgresDB.getTrackedGame(gameID)

        # else, we can do things with it.
        message = Array.new

        # Name
        message.push("Game Summary for: #{_gameAlias}:\n")
        # games have done runs in
        categoryList = ""
        totalSubmittedRuns = 0
        totalSubmittedWRs = 0
        game.categories.each do |key, category|
          categoryList += "#{category.category_name}, "
          totalSubmittedRuns += category.number_submitted_runs
          totalSubmittedWRs += category.number_submitted_wrs
        end
        message.push("Tracked categories: #{categoryList}")
        # Number of submitted WRs
        # Number of submitted runs
        message.push("Number of Submitted World Records: #{totalSubmittedWRs}")
        message.push("Number of Submitted Runs: #{totalSubmittedRuns}")
        message.push("New runs for this game will be announced in channel: #{game.announce_channel}")

        _event << Util.arrayToCodeBlock(message)

      end # end of command body
    end
  end
end
