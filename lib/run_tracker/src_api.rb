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

      foundGame = gameData['data']
      categoryLink = getFwdLink('categories', foundGame['links'])
      return TrackedGame.new(foundGame['id'], foundGame['names']['international'],
                            Util.jsonRequest(categoryLink)['data'],
                            getGameMods(foundGame['moderators']),
                            game_alias: foundGame['abbreviation'])
    end

    ##
    # Resolves all of the moderators user names
    def self.getGameMods(mods)

      modList = Hash.new
      mods.each do |id, _|
        mod = Util.jsonRequest("#{API_URL}users/#{id}")['data']
        modList[mod['names']['international']] = Moderator.new(id, mod['names']['international'])
      end
      return modList
    end

    ##
    # Given a game's category API link, return

    ##
    # Will pull all current data from a game's leaderboard
    def self.seedDatabaseNewGame(gameID)

      # NOTE as of right now, we are not supporting ILs

      # Need to get all the categories
      # Need to get all the runners
      # Need to get all the runner's runs
      # runs....orderby.....direction


    end

  end
end
