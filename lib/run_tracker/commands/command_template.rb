module RunTracker
  module CommandLoader
    module CommandName # TODO: change
      extend Discordrb::Commands::CommandContainer

      command(:addgame, description: '',
                        usage: '',
                        min_args: 1,
                        max_args: 1) do |_event| # TODO: config

        # Command Body
        puts 'stub'
      end
    end
  end
end
