module RunTracker
  module CommandLoader
    module AddGame
      extend Discordrb::Commands::CommandContainer

      command(:addgame, description: 'Adds a game to the tracking list',
                    usage: 'add <query>', min_args: 1) do |event, *args|

        next "Test"
        # unneeded return? nil
      end
    end
  end
end
