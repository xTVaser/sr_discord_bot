module RunTracker
  ##
  # Holds all related functions for dealing with speedrun.com API
  module SrcAPI
    API_URL = 'https://www.speedrun.com/api/v1/'.freeze

    ##
    # Returns the forward link given the rel key
    def self.getFwdLink(key, links)
      links.each do |link|
        return link['uri'] if link['rel'].casecmp(key).zero?
      end
      nil
    end

    ##
    # Given a user's ID, return their name
    def self.getUserName(id)
      Util.jsonRequest("#{API_URL}users/#{id}")['data']['names']['international']
    end

    def self.getUserInfo(id)
      Util.jsonRequest("#{API_URL}users/#{id}")['data']
    end

    ##
    # We should only have 1 game information in this case
    # as ID requests only return 1 result
    def self.getGameInfoFromID(gameData)
      # Verify the game data first
      if gameData.length > 1
        raise 'Game ID Malformed, returning multiple games
              (this should be impossible).'
      elsif gameData.key?('status')
        raise 'Game ID Malformed, no game found.'
      end

      foundGame = gameData['data']
      categoryLink = getFwdLink('categories', foundGame['links'])

      # remove all whitespace for default game alias
      gameAlias = foundGame['abbreviation']
      if gameAlias.nil?
        gameAlias = foundGame['names']['international'].gsub(/\s+/, '')
      end

      categoryResults = getGameCategories(Util.jsonRequest(categoryLink)['data'], foundGame['id'], gameAlias)
      categoryList = categoryResults.first
      # Add the category aliases to the alias table
      aliasList = categoryResults.last
      aliasList[gameAlias] = ['game', foundGame['id']]
      # TODO: this should be moved, not transactional
      SQLiteDB.insertNewAliases(aliasList)

      modList = getGameMods(foundGame['moderators'])
      SeedDB.getGameRunners(foundGame['id'], foundGame['names']['international'], categoryList, modList)

      [gameAlias, TrackedGame.new(foundGame['id'],
                                  foundGame['names']['international'],
                                  foundGame['assets']['cover-large']['uri'],
                                  categoryList, modList)]
    end

    ##
    # Resolves all of the moderators user names
    def self.getGameMods(mods)
      modList = {}
      mods.each do |id, _|
        modList[id] = Moderator.new(id, getUserName(id))
      end
      modList
    end

    ##
    # Resolves all of the categories
    # Subcategories are made into their own categories with a composite key of [id-variableID:variableValue]
    # This category ID can be resolved with a seperate method when the user calls
    def self.getGameCategories(categories, _gameID, gameAlias)
      categoryList = {}
      aliasList = {}
      categories.each do |category|
        # NOTE We are not supporting ILs (individual levels) right now, skip them
        next if category['type'].casecmp('per-level').zero?

        # Get the categories subcategories variables
        variableResults = Util.jsonRequest(getFwdLink('variables', category['links']))['data']
        subCategories = {}
        variableResults.each do |variable|
          next unless variable['is-subcategory'] == true
          variable['values']['values'].each do |key, value|
            subCategories["#{variable['id']}:#{key}"] = [value['label'], value['rules']]
          end
        end
        if subCategories.length <= 0 # if there are no subcategories then just do it normally
          categoryList["#{category['id']}-:"] = Category.new(category['id'], category['name'], category['rules'], nil)
          # remove all whitespace for default alias
          aliasList["#{gameAlias}-#{(category['name'].gsub(/\s+/, '')).downcase}"] = ['category', "#{category['id']}-:"]
        else # else there are, so concat the id, name, and rules onto the category
          subCategories.each do |key, value|
            categoryList["#{category['id']}-#{key}"] = Category.new("#{category['id']}-#{key}",
                                                                    "#{category['name']} - #{value.first}",
                                                                    "#{category['rules']}#{value.last}",
                                                                    subCategories)
            # remove all whitespace for default alias
            subCategoryAlias = "#{category['name']}#{value.first}"
            aliasList["#{gameAlias}-#{(subCategoryAlias.gsub(/\s+/, '')).downcase}"] = ['category', "#{category['id']}-#{key}"]
          end
        end

      end # end category loop
      [categoryList, aliasList]
    end # end func



    ##
    # Given a run ID, get its associated information
    # this is a work in progress, more is extracted as needed
    def self.getRunInfo(runID)

      info = Util.jsonRequest("#{API_URL}runs/#{runID}")['data']
      # TODO: this doesnt handle 404 not found
      # guaranteed to be just one run

      runInfo = Hash.new
      runInfo['time'] = Util.secondsToTime(info['times']['primary_t'])
      # name
      if info['players'].first['rel'].casecmp('guest').zero?
        runInfo['name'] = info['players'].first['name']
      else
        runInfo['name'] = self.getUserName(info['players'].first['id'])
      end
      runInfo['srcLink'] = info['weblink']

      if info['videos'] == nil
        runInfo['videoLink'] = "No Video"
      else
        runInfo['videoLink'] = info['videos']['links'].first['uri']
      end

      runDate = nil
      # If the run has no date, fallback to the verified date
      if !info['date'].nil?
        runDate = Date.strptime(info['date'], '%Y-%m-%d')
      elsif !info['status']['verify-date'].nil?
        # TODO:: cant strp date and time at same time? loses accuracy, fix
        runDate = Date.strptime(info['status']['verify-date'].split('T').first, '%Y-%m-%d') 
      end

      runInfo['date'] = runDate

      return runInfo
    end # end of func
  end # end SRC_API module
end
