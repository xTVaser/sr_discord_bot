module RunTracker
  module CommandLoader
    module Set
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 3, time_span: 10, delay: 1


      command(:set, bucket: :limiter,
                    description: 'Allows the setting and changing of access levels for users of the server through @ mentions.',
                    usage: '!set <user> <permission> (permission levels: `admin`, `mod`, `user`).',
                    rate_limit_message: 'Andy Gavin says to wait %time% more second(s)!',
                    min_args: 2,
                    max_args: 2) do |event, mention, permission|

        # Command Body
        level = 0

        # Sets the level variable to the desired access level.
        puts case permission
        when 'admin'
          level = 3
          RTBot.send_message(event.channel, 'Admin Permission Selected.')
        when 'mod'
          level = 2
          RTBot.send_message(event.channel, 'Mod Permission Selected.')
        when 'user'
          level = 1
          RTBot.send_message(event.channel, "User Permission Selected.")
        else
          RTBot.send_message(event.channel, "Invalid Permission Selected. Please refer to command usage.")
        end

        # Encapsulate the user from the mention statement.
        user = event.bot.parse_mention(mention)

        begin
          if level != 0
            RTBot.set_user_permission(user.id, level) # Set the user's permission level during this instance

            # If the user is not in the database then we insert them into the table and save their access level.
            begin

              PostgresDB::Conn.prepare('statement1', 'insert into public."managers"("user_id", access_level) values ($1, $2 )')
              PostgresDB::Conn.exec_prepared('statement1', [user.id, level])

            rescue PG::UniqueViolation # Otherwise if they are already in the database we update their access level.

              PostgresDB::Conn.prepare('statement2', 'update public."managers" set access_level = $1 where user_id = $2')
              PostgresDB::Conn.exec_prepared('statement2', [level, user.id])

            end

            # Send verbal confirmation of access level setting.
            event << "Permission set for user #{user.name}!"
          end
        rescue Exception => e # TODO: Change this to show an error message instead of the stack trace.
          e.backtrace.inspect + e.message
        end


      end
    end
  end
end
