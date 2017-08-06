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
        if permission.casecmp('admin')
          level = :administrator
        elsif permission.casecmp('mod')
          level = :kick_members
        elsif permission.casecmp('user')
          level = :create_instant_invite
        end

        user = event.bot.parse_mention(mention)
        begin
          if level != -1
            RTBot.set_user_permission(user, level)
            event << "Permission set for user #{user.name}!"
            event << "#{RTBot.permission?(user, level, event.server)}"
          end
        rescue Exception => e
          e.backtrace.inspect + e.message
        end


      end
    end
  end
end
