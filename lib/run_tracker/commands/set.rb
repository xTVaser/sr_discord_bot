module RunTracker
  module CommandLoader
    module Set
      # Require all command files.
      Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each do |file|
        require file
      end
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 3, time_span: 10, delay: 1


      command(:set, bucket: :limiter,
                    description: 'Allows the setting and changing of access level requirements for certain commands server-wide.',
                    usage: '!set <command> <value> ()',
                    rate_limit_message: 'Andy Gavin says to wait %time% more second(s)!',
                    min_args: 2) do |event, command, value|

        # Command Body
        #begin
          #if (value > 2 || value < 0)
          #  RTBot.send_message(event.channel, "Invalid value! Values can range from 0 to 2 (0 = User, 1 = Mod, 2 = Admin)")
          if command.casecmp('addgame')
            command = AddGame
            command.permission_level(value)
            RTBot.send_message(event.channel, "Permissions set for `addgame`!")
          end
        #rescue
          #RTBot.send_message(_event.channel, "Command Not Found!")
        #end


        #@commands.each do |command|
        #  if type.casecmp('command').zero?
        #    RTBot.send_message(_event.channel, "Invalid Command! Type `!list commands` to see the list of commands this bot has.")
        #  end
        #end

        #RTBot.send_message(DevChannelID, "Test")

      end
    end
  end
end
