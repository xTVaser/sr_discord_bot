module RunTracker
  module CommandLoader
    module StatsGame
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:statsgame, description: 'Displays stats for a given tracked game',
                        usage: "~statsgame <alias>",
                        permission_level: PERM_USER,
                        rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                        bucket: :limiter,
                        min_args: 1,
                        max_args: 1) do |_event, _gameAlias|

        # Command Body
        gameID = PostgresDB.findID(_gameAlias)
        if gameID == nil
          _event << "No game found with that alias, use ~listgames to view current aliases"
          next
        end
        # First verify if that game is even tracked (by getting it)
        game = PostgresDB.getTrackedGame(gameID)

        # else, we can do things with it.
        message = Array.new

        # Name
        message.push(">Game Summary for: <#{_gameAlias}>:\n")
        message.push("Categories <~statscategory categoryAlias>:")
        message.push("============")
        # games have done runs in
        totalSubmittedRuns = 0
        totalSubmittedWRs = 0
        game.categories.each do |key, category|
          message.push("< #{category.category_name} >")
          totalSubmittedRuns += category.number_submitted_runs
          totalSubmittedWRs += category.number_submitted_wrs
        end
        # Number of submitted WRs
        # Number of submitted runs
        message.push("\n>Number of Submitted World Records: <#{totalSubmittedWRs}>")
        message.push(">Number of Submitted Runs: <#{totalSubmittedRuns}>")

        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end of command body
    end
  end
end
