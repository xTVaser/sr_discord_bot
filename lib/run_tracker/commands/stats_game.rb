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
        gameID = SQLiteDB.findID(_gameAlias)
        if gameID == nil
          _event << "No game found with that alias, use ~listgames to view current aliases"
          next
        end
        # First verify if that game is even tracked (by getting it)
        game = SQLiteDB.getTrackedGame(gameID)

        # else, we can do things with it.
        embed = Discordrb::Webhooks::Embed.new(
          title: "Game Summary for - #{_gameAlias}",
          description: "To View Category Information `~statscategory categoryAlias`",
          thumbnail: {
            url: game.cover_url
          },
          footer: {
            text: "To View Category Aliases `~listcategories #{_gameAlias}`\n~help to view a list of available commands"
          }
        )
        embed.colour = "#1AB5FF"

        # Name
        # games have done runs in
        totalSubmittedRuns = 0
        totalSubmittedWRs = 0
        game.categories.each do |key, category|
          totalSubmittedRuns += category.number_submitted_runs
          totalSubmittedWRs += category.number_submitted_wrs
        end
        # Number of submitted WRs
        # Number of submitted runs
        embed.add_field(
          name: "Number of Submitted World Records",
          value: totalSubmittedWRs,
          inline: true
        )
        embed.add_field(
          name: "Number of Submitted Runs",
          value: totalSubmittedRuns,
          inline: true
        )
        RTBot.send_message(_event.channel.id, "", false, embed)
      end # end of command body
    end
  end
end
