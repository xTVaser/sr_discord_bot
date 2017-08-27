module RunTracker
  module CommandLoader
    module StatsRunner
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:statsrunner, description: 'Displays all or a particular stat for a given runner',
                        usage: "!statsrunner <runner name> Optional:{<game alias> <category alias>}",
                        permission_level: PERM_USER,
                        rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                        bucket: :limiter,
                        min_args: 1,
                        max_args: 3) do |_event, _runnerName, _type, _alias|

        # Command Body

        # First verify if that runner even exists
        runners = PostgresDB.getCurrentRunners
        theRunner = nil
        runners.each do |key, runner|
          if runner.src_name.casecmp(_runnerName.downcase).zero? or
            (runner.src_name.casecmp('guest').zero? and runner.src_id.casecmp(_runnerName.downcase).zero?)
            theRunner = runner
          end
        end

        # didnt find it
        if theRunner == nil
          # TODO add fuzzy search with API to get the id if cant find anything
          _event << "No runner found with that name, try again"
          next
        end

        # else, we can do things with it.
        message = Array.new
        # If only the runner name was supplied, print out a summary of the runner
        if _type == nil and _alias == nil
          # Name
          message.push(">Runner Summary for <#{_runnerName}>:\n")
          message.push("Runs of Games That are Tracked")
          message.push("============")
          # games have done runs in
          theRunner.historic_runs.each do |key, game|
            message.push("< #{game.src_name} >")
          end
          # Number of submitted WRs
          # Number of submitted runs
          message.push("\n>Number of Submitted World Records: <#{theRunner.num_submitted_wrs}>")
          message.push(">Number of Submitted Runs: <#{theRunner.num_submitted_runs}>")
          # Total time convert to hours across all runs
          message.push(">Total Time spent across all runs: <#{(theRunner.total_time_overall/3600.0).round(2)}> hrs")
        # If we are only given the game alias
        elsif _type.downcase.casecmp('game').zero? and _alias != nil
          # Check to see if alias even exists
          # TODO cleant his up with postgres util fundtion findID
          PostgresDB::Conn.prepare("find_alias", "SELECT * FROM public.\"aliases\" WHERE alias= $1 and type='game'")
          aliasResults = PostgresDB::Conn.exec_prepared('find_alias', [_alias])
          if aliasResults.ntuples < 1
            PostgresDB::Conn.exec('DEALLOCATE find_alias')
            _event << "Game Alias not found use !listgames to see the current aliases"
            next
          end
          PostgresDB::Conn.exec('DEALLOCATE find_alias')

          # Check to see if that runner has done runs of that game
          foundGame = nil
          theRunner.historic_runs.each do |key, game|
            if key.casecmp(aliasResults.first['id']).zero?
              foundGame = game
            end
          end
          if foundGame == nil
            _event << "That runner has not done a run of that game"
            next
          end

          # Name
          message.push(">Runner Summary for <#{_runnerName}> in Game <#{_alias}>:\n")
          # categories have done runs in
          message.push("Categories That Have Done Runs in:")
          message.push("============")
          foundGame.categories.each do |key, category|
            if category.num_submitted_runs > 0
              message.push("< #{category.src_name} >")
            end
          end
          # Number of submitted WRs
          # Number of submitted runs
          message.push("\n>Number of Submitted World Records: <#{foundGame.num_previous_wrs}>") # TODO refactor this across later
          message.push(">Number of Submitted Runs: <#{foundGame.num_submitted_runs}>")
          # Total time convert to hours across all runs
          message.push(">Total Time spent across all runs: <#{(foundGame.total_time_overall/3600.0).round(2)}> hrs")

        # Otherwise print category information
        elsif _type.downcase.casecmp('category').zero? and _alias != nil
          # Check to see if alias even exists
          # TODO cleant his up with postgres util fundtion findID
          # Check to see if they've done the category
          PostgresDB::Conn.prepare("find_alias", "SELECT * FROM public.\"aliases\" WHERE alias= $1 and type='category'")
          aliasResults = PostgresDB::Conn.exec_prepared('find_alias', [_alias])
          if aliasResults.ntuples < 1
            PostgresDB::Conn.exec('DEALLOCATE find_alias')
            _event << "Category Alias not found use !listcategories <gameAlias> to see the current aliases"
            next
          end
          PostgresDB::Conn.exec('DEALLOCATE find_alias')

          gameAlias = aliasResults.first['alias'].split('-').first

          gameID = PostgresDB.findID(gameAlias)

          # Check to see if that runner has done runs of that game
          foundGame = nil
          theRunner.historic_runs.each do |key, game|
            if key.casecmp(gameID).zero?
              foundGame = game
            end
          end
          if foundGame == nil
            _event << "That runner has not done a run of that game"
            next
          end

          # Check to see if that runner has done runs of that category
          category = foundGame.categories[aliasResults.first['id']]
          if category.num_submitted_runs <= 0
            _event << "That runner has not done a run of that category for that category!"
            next
          end

          # Name
          message.push(">Runner Summary for <#{_runnerName}> in Game <#{gameAlias}> in Category <#{_alias}>:\n")
          # milestones
          message.push("Milestones for this Category")
          message.push("============")
          milestoneList = ""
          category.milestones.each do |label, runID|
            message.push("[#{label}](#{runID})")
          end
          # Number of submitted WRs
          # Number of submitted runs
          message.push("\n>Number of Submitted World Records: <#{category.num_previous_wrs}>") # TODO refactor this across later
          message.push(">Number of Submitted Runs: <#{category.num_submitted_runs}>")
          # Total time convert to hours across all runs
          message.push(">Total Time spent across all runs: <#{(category.total_time_overall/3600.0).round(2)}> hrs")
        else
          _event << "!statsrunner <runner name> Optional:{<game alias> <category alias>}"
          next
        end

        _event << Util.arrayToCodeBlock(message, highlighting: 'md')

      end # end of command body
    end
  end
end
