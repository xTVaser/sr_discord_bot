module RunTracker
  ##
  # Holds all related functions for dealing with speedrun.com API
  module SrcAPI
    API_URL = 'http://www.speedrun.com/api/v1/'.freeze

    ##
    # Returns the forward link given the rel key
    def self.getFwdLink(key, links)
      links.each do |link|
        if link['rel'].casecmp(key).zero?
          return link['uri']
        end
      end
    end

    ##
    # We should only have 1 game information in this case
    # as ID requests only return 1 result
    def self.getGameInfoFromID(gameData)
      # Verify the game data first
      if gameData.length > 1
        raise 'Game ID Malformed, returning multiple games
              (this should be impossible).' # TODO: return when wrong, check
      elsif gameData.key?('status')
        raise 'Game ID Malformed, no game found.'
      end

      # TODO put this processing in a seperate thread for immediate feedback

      foundGame = gameData['data']
      categoryLink = getFwdLink('categories', foundGame['links'])
      categoryList = getGameCategories(Util.jsonRequest(categoryLink))
      modList = getGameMods(foundGame['moderators'])
      getGameRunners(foundGame['id'], foundGame['names']['international'], foundGame['abbreviation'], categoryList, modList)

      return TrackedGame.new(foundGame['id'],
                             foundGame['names']['international'],
                             categoryList, modList,
                             game_alias: foundGame['abbreviation'])
    end

    ##
    # Resolves all of the moderators user names
    def self.getGameMods(mods)
      modList = Hash.new
      mods.each do |id, _|
        mod = Util.jsonRequest("#{API_URL}users/#{id}")['data']
        modList[mod['id']] = Moderator.new(id, mod['names']['international'])
      end
      return modList
    end

    ##
    # Resolves all of the categories
    # TODO Add API calls to get current WR time
    # TODO needs to support sub categories /variables endpoint, just make each subcategory its own category
    def self.getGameCategories(categories)
      categoryList = Hash.new
      categories.each do |category|
        categoryList[category['id']] = Category.new(category['id'], category['name'], category['rules'])
      end
      return categoryList
    end

    ##
    # TODO this needs to be significantly refactored after it works
    # Gathers all of the runners, their runs, their current stats
    # At the same time it also counts the moderators verified runs, and last verified run date
    # Also determines the current stats for each category
    # Will pull all current data from a game's leaderboard
    # categoryList and modList are expected to be hashes keyed with their respective SRC ids
    def self.getGameRunners(gameID, gameName, gameAbbrv, categoryList, modList)

      currentRunnerList = PostgresDB.getCurrentRunners()
      newRunnerList = Hash.new
      # TODO when add in subcategory support, this will only have to change
      # by allowing to include the variable into the API call
      categoryList.each do |category| # Loop through every category

        currentWRTime = MaxInteger
        currentWRID = ''
        currentWRDate = nil

        numSubmittedRuns = 0
        numSubmittedWRs = 0

        longestHeldWR = 0
        longestHeldWRID = ''

        categoryRuns = Util.jsonRequest("#{API_URL}runs
                                        ?game=#{gameID}
                                        &category=#{category.category_id}
                                        &orderby=date&direction=asc&max=200")['data']

        # Add to runner information
        # NOTE this causes a problem if the runner ever gets a SRC account in the future
        runnerKey = ''
        if run['players']['rel'] == 'guest'
          runnerKey = run['players']['name']
        else
          runnerKey = run['players']['id']
        end
        # If we havnt started tracking this runner before, init
        runner = nil
        if !currentRunnerList.key?(runnerKey)
          runner = Runner.new()
          runner.historic_runs[gameID] = RunnerGame.new(gameID, gameName, gameAbbrv)
          runner.historic_runs[gameID][category.category_id] = RunnerCategory.new(category.category_id, category.category_name)
        else
          runner = currentRunnerList['runnerKey']
          # Has this runner ran this game before, init the game and category
          if !runner.historic_runs.key?(gameID)
            runner.historic_runs[gameID] = RunnerGame.new(gameID, gameName, gameAbbrv)
            runner.historic_runs[gameID][category.category_id] = RunnerCategory.new(category.category_id, category.category_name)
          # If the runner has ran the game before, but not the category yet
          elsif !runner.historic_runs[gameID].key?(category_id)
            runner.historic_runs[gameID][category.category_id] = RunnerCategory.new(category.category_id, category.category_name)
          end # else its fine
        end

        loop do
          categoryRuns.each do |run|

            numSubmittedRuns += 1
            runner.num_submitted_runs += 1
            runner.num_submitted_wrs += 1
            runner.total_time_overall += run['times']['primary_t']
            runner.historic_runs[gameID].num_submitted_runs += 1
            runner.historic_runs[gameID].total_time_overall += run['times']['primary_t'] # TODO probably convert these to hours here, util function
            runner.historic_runs[gameID][category.category_id].total_time_overall += run['times']['primary_t']

            # Check if the run is a new milestone for this runner
            nextMilestone = Util.nextMilestone(runner.historic_runs[gameID][category.total_time_overall])
            if nextMilestone >= run['times']['primary_t']
              runner.historic_runs[gameID][category.category_id].milestones["#{nextMilestone}"] = run['id']
            end

            # Update if PB
            if run['times']['primary_t'] < runner.historic_runs[gameID][category.category_id].current_pb_time
              runner.historic_runs[gameID][category.category_id].current_pb_time = run['times']['primary_t']
              runner.historic_runs[gameID][category.category_id].current_pb_id = run['id']
            end

            # Check if new WR
            # TODO, support ties
            if currentWRTime > run['times']['primary_t']

              runner.historic_runs[gameID].num_previous_wrs += 1
              runner.historic_runs[gameID][category.category_id].num_previous_wrs += 1

              # Update state
              currentWRTime = run['times']['primary_t']

              runDate = nil
              # If the run has no date, fallback to the verified date
              if !run['date'].nil?
                runDate = Date.strptime(run['date'], '%Y-%m-%d')
              elsif !run['status']['verify-date'].nil?
                runDate = Date.strptime(run['status']['verify-date'], '%Y-%m-%dT%H:%M%SZ')
              end

              # Before we scrap the old date, see if it's the new longest WR
              if currentWRDate.nil? && !runDate.nil?
                currentWRDate = runDate
              elsif !currentWRDate.nil? && !runDate.nil?
                if (runDate - currentWRDate).to_i > longestHeldWR
                  longestHeldWR = (runDate - currentWRDate).to_i
                  longestHeldWRID = currentWRID
                end
              end

              currentWRID = run['id']
              currentWRDate = runDate
              numSubmittedWRs += 1

              # Moderator stuff
              if !run['status']['examiner'].nil?
                mod = modList[run['status']['examiner']]
                mod.total_verified_runs += 1
                if mod.last_verified_run_date < run['status']['verify-date']
                  mod.last_verified_run_date = run['status']['verify-date']
                end
              end
            end
          end

          # If no more pages to loop through
          break if categoryRuns['links'] == []
          categoryRuns = Util.jsonRequest(getFwdLink('next'), categoryRuns['links'])['data']
        end # end of category's runs loop
      end # end of category loop

      # Update current runners
      PostgresDB.updateCurrentRunners(currentRunners)
      # Insert new runners
      PostgresDB.insertNewRunners(newRunners)
    end
  end
end
