module RunTracker
  module CommandLoader

    module Set
      extend Discordrb::Commands::CommandContainer
      command(:set, description: "Allows the setting and changing of access level requirements for certain commands server-wide.",
                    usage: "set <command> <value>", min_args: 2,
                    required_permissions: [:manage_server]) do |event, command, value|
        next "Test"

      end
    end
  end
end
