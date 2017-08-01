module RunTracker
  module CommandLoader
    module AddGame
      extend Discordrb::Commands::CommandContainer

      command(:addgame, description: 'Add a game to the list of tracked games.',
                        usage: '!addgame <id/name> <game-name/game-id> {optional: <alias>}',
                        min_args: 2,
                        max_args: 3,
                        ) do |event, type, search_field, game_alias| # TODO needs rate limiting added to all these commands

        # Command Body
        # Check to see if the command syntax was valid
        unless type.downcase == "id" or search_field.downcase == "name"
          RTBot.send_message(DevChannelID, "Invalid syntax for command `addgame`!")
          next RTBot.send_message(DevChannelID, "Usage: `!addgame <id/name> <game-name/game-id> {optional: <alias>}`")
        end

        # If the user wants to search by ID, check for ID with SRC API
        # http://www.speedrun.com/api/v1/games/<id>
        if type.downcase == "id"
          json = Util.jsonRequest("http://www.speedrun.com/api/v1/games/" + search_field)
          SrcAPI.getGameInfo(json)
        end



















        RTBot.send_message(DevChannelID, "shouldnt get to this line")






      end
    end
  end
end
