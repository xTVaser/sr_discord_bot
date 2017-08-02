module RunTracker
  ##
  # Holds all related functions for dealing with speedrun.com API
  module SrcAPI
    API_URL = 'http://www.speedrun.com/api/v1/'.freeze

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
      categoryLink = foundGame['links'][3]['uri'] # HACK: for now TODO need to search for rel key
      TrackedGame.new(foundGame['id'], foundGame['names']['international'],
                      Util.jsonRequest(categoryLink)['data'],
                      foundGame['moderators'],
                      game_alias: foundGame['abbreviation'])
    end
  end
end
