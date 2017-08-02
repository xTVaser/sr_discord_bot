module RunTracker
  module CommandLoader
    module Set
      extend Discordrb::Commands::CommandContainer
      command(:set, description: 'Allows the setting and changing of access level requirements for certain commands server-wide.',
                    usage: '!set <command> <value>',
                    min_args: 2) do |_event, _command, _value|

        RTBot.send_message(DevChannelID, "Test")


      end
    end
  end
end
