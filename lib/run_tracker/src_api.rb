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
      return nil
    end

    ##
    # Given a user's ID, return their name
    def self.getUserName(id)
      return Util.jsonRequest("#{API_URL}users/#{id}")['data']['names']['international']
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

      categoryResults = getGameCategories(Util.jsonRequest(categoryLink)['data'], foundGame['id'])
      categoryList = categoryResults.first
      # Add the aliases to the alias table
      aliasList = categoryResults.last
      # remove all whitespace for default game alias
      gameAlias = foundGame['abbreviation']
      if gameAlias == nil
        gameAlias = foundGame['names']['international'].gsub(/\s+/, "")
      end
      aliasList[gameAlias] = ['game', foundGame['id']]
      PostgresDB.insertNewAliases(aliasList)

      modList = getGameMods(foundGame['moderators'])
      SeedDB.getGameRunners(foundGame['id'], foundGame['names']['international'], categoryList, modList)

      return [gameAlias, TrackedGame.new(foundGame['id'],
                             foundGame['names']['international'],
                             categoryList, modList)]
    end

    ##
    # Resolves all of the moderators user names
    def self.getGameMods(mods)
      modList = Hash.new
      mods.each do |id, _|
        modList[id] = Moderator.new(id, getUserName(id))
      end
      return modList
    end

    ##
    # Resolves all of the categories
    # Subcategories are made into their own categories with a composite key of [id-variableID:variableValue]
    # This category ID can be resolved with a seperate method when the user calls
    def self.getGameCategories(categories, gameID)

      categoryList = Hash.new
      aliasList = Hash.new
      categories.each do |category|

        # NOTE We are not supporting ILs (individual levels) right now, skip them
        if category['type'].casecmp('per-level').zero?
          next
        end

        # Get the categories subcategories variables
        variableResults = Util.jsonRequest(getFwdLink('variables', category['links']))['data']
        subCategories = Hash.new
        variableResults.each do |variable|
          if variable['is-subcategory'] == true
            variable['values']['values'].each do |key, value|
              subCategories["#{variable['id']}:#{key}"] = [value['label'], value['rules']]
            end
          end
        end
        categoryKey = ''
        if subCategories.length <= 0 # if there are no subcategories then just do it normally
          categoryKey = "#{category['id']}-:"
          categoryList["#{category['id']}-:"] = Category.new(category['id'], category['name'], category['rules'], nil)
        else # else there are, so concat the id, name, and rules onto the category
          subCategories.each do |key, value|
            categoryKey = "#{category['id']}-#{key}"
            categoryList["#{category['id']}-#{key}"] = Category.new("#{category['id']}-#{key}",
                                                         "#{category['name']}#{value.first}",
                                                         "#{category['rules']}#{value.last}",
                                                         subCategories)
          end
        end
        # remove all whitespace for default alias
        aliasList[categoryKey] = ['category', category['name'].gsub(/\s+/, "")]
      end # end category loop
      return [categoryList, aliasList]
    end

  end # end SRC_API module
end
