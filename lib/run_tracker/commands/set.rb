module RunTracker
  module CommandLoader
    module Set
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 3, time_span: 10, delay: 1


      command(:set, bucket: :limiter,
                    description: 'Allows the setting and changing of access level requirements for certain commands server-wide.',
                    usage: '!set <user> <permission> ()',
                    rate_limit_message: 'Andy Gavin says to wait %time% more second(s)!',
                    min_args: 2) do |event, mention, permission|

        # Command Body
        level = -1
        if permission.casecmp('admin') # NOTE fucked
          level = 3 # NOTE hardcoded :administrator
          RTBot.send_message(DevChannelID, 'Admin Permission Selected')
        elsif permission.casecmp('mod')
          level = 2
          RTBot.send_message(DevChannelID, 'Mod Permission Selected')
        elsif permission.casecmp('user') # NOTE default not needed to be set on user
          level = 1
          RTBot.send_message(DevChannelID, 'User Permission Selected')
        end

        user = event.bot.parse_mention(mention)
        begin
          if level != -1
            RTBot.set_user_permission(user.id, level)
            event << "Permission set for user #{user.name}!"
          end
        rescue Exception => e
          e.backtrace.inspect + e.message
        end


      end
    end
  end
end
