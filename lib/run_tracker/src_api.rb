module RunTracker
  module SrcAPI

    API_URL = "http://www.speedrun.com/api/v1/"

    ## We should only have 1 game information in this case, as ID requests only return 1 result
    def self.getGameInfoFromID(gameData)

      # Verify the game data first
      if gameData.length > 1
        raise "Game ID Malformed, returning multiple games (this should be impossible)." # TODO return when wrong, check
      elsif gameData.has_key?('status')
        raise "Game ID Malformed, no game found."
      end

      foundGame = gameData['data']
      categoryLink = foundGame['links'][3]['uri'] # hack for now TODO need to search for rel key
      return TrackedGame.new(foundGame['id'], foundGame['names']['international'],
                              Util.jsonRequest(categoryLink)['data'],
                              foundGame['moderators'],
                              game_alias: foundGame['abbreviation'])

    end

  end
end
