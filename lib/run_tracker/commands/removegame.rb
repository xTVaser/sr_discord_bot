module RunTracker
  module CommandLoader
    module RemoveGame
      extend Discordrb::Commands::CommandContainer

      command(:removegame, description: "Removes a game from the list of tracked games.",
                           usage: "!removegame <id/name>",
                           required_permissions: [:administrator],
                           min_args: 1,
                           max_args: 1) do |event, search_field|

        RTBot.send_message(event.channel, "Test")

      end
    end
  end
end
