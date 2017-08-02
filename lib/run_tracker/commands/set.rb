module RunTracker
  module CommandLoader
    module Set
      extend Discordrb::Commands::CommandContainer
      bucket :limiter, limit: 3, time_span: 60, delay: 10
      command(:set, bucket: :limiter,
                    description: 'Allows the setting and changing of access level requirements for certain commands server-wide.',
                    usage: '!set <command> <value>',
                    rate_limit_message: 'Andy Gavin says to wait %time% more second(s)!',
                    min_args: 2) do |_event, _command, _value|

        RTBot.send_message(DevChannelID, "Test")

      end
    end
  end
end
