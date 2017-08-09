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
      categoryList = getGameCategories(Util.jsonRequest(categoryLink)['data'], foundGame['id'])
      modList = getGameMods(foundGame['moderators'])
      SeedDB.getGameRunners(foundGame['id'], foundGame['names']['international'], foundGame['abbreviation'], categoryList, modList)

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
    # Subcategories are made into their own categories with a composite key of [id-variableID:variableValue]
    # This category ID can be resolved with a seperate method when the user calls
    def self.getGameCategories(categories, gameID)

      categoryList = Hash.new
      categories.each do |category|
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
        if subCategories.length <= 0 # if there are no subcategories then just do it normally
          categoryList["#{category['id']}-:"] = Category.new(category['id'], category['name'], category['rules'], nil)
        else # else there are, so concat the id, name, and rules onto the category
          subCategories.each do |key, value|
            categoryList["#{category['id']}-#{key}"] = Category.new("#{category['id']}-#{key}",
                                                         "#{category['name']}#{value.first}",
                                                         "#{category['rules']}#{value.last}",
                                                         subCategories)
          end
        end
      end # end category loop
      return categoryList
    end

  end # end SRC_API module
end
