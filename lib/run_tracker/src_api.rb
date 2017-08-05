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
      getGameRunners(foundGame['id'], categoryList, modList)

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
    # Gathers all of the runners, their runs, their current stats
    # At the same time it also counts the moderators verified runs, and last verified run date
    # Also determines the current stats for each category
    # Will pull all current data from a game's leaderboard
    # categoryList and modList are expected to be hashes keyed with their respective SRC ids
    def self.getGameRunners(gameID, categoryList, modList)

      runnerList = Hash.new
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
        &category=#{category['id']}
        &orderby=date&direction=asc&max=200")['data']

        loop do

          categoryRuns.each do |run|

            numSubmittedRuns += 1
            # Check if new WR
            # TODO, support ties
            if currentWRTime > run['times']['primary_t']
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

              # Add to runner information
              runnerKey = ''
              if run['players']['rel'] == 'guest'
                runnerKey = run['players']['name']
              else
                runnerKey = run['players']['id']
              end
              # If we havnt started tracking this runner before, init
              runner = nil
              if !runnerList.key?(runnerKey)
                runner = Runner.new() # TODO make runner oject
              else
                runner = runnerList['runnerKey']
              end




            end
          end


          # If no more pages to loop through
          break if categoryRuns['links'] == []
          # get next page
        end
      end


    end

  end
end
