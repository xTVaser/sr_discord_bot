module RunTracker
  module CommandLoader
    module Grant
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 3, time_span: 10, delay: 1

      command(:grant, bucket: :limiter,
                    description: 'Allows the setting and changing of access levels for users of the server through @ mentions.',
                    usage: '!grant <@user> <permission> (permission levels: `admin`, `mod`).',
                    rate_limit_message: 'Andy Gavin says to wait %time% more second(s)!',
                    min_args: 2,
                    max_args: 2) do |_event, mention, permission|

        # Command Body
        # Encapsulate the user from the mention statement.
        user = _event.bot.parse_mention(mention)
        if user == nil
          _event << "User not found in this server, try again."
          next
        end

        level = 0
        # Sets the level variable to the desired access level.
        case permission
          when 'admin'
           level = 2
            _event << 'Admin Permission Selected.'
          when 'mod'
            level = 1
            _event << 'Mod Permission Selected.'
          else
            _event << 'Invalid Permission Selected. Please refer to command usage.'
            next
        end

        begin
          RTBot.set_user_permission(user.id, level) # Set the user's permission level during this instance

          # If the user is not in the database then we insert them into the table and save their access level.
          begin
            PostgresDB::Conn.prepare('insert_grant_permission', 'insert into public."managers"("user_id", access_level) values ($1, $2 )')
            PostgresDB::Conn.exec_prepared('insert_grant_permission', [user.id, level])
            PostgresDB::Conn.exec('DEALLOCATE insert_grant_permission')
          rescue PG::UniqueViolation # Otherwise if they are already in the database we update their access level.
            PostgresDB::Conn.exec('DEALLOCATE insert_grant_permission')
            PostgresDB::Conn.prepare('update_grant_permission', 'update public."managers" set access_level = $1 where user_id = $2')
            PostgresDB::Conn.exec_prepared('update_grant_permission', [level, user.id])
            PostgresDB::Conn.exec('DEALLOCATE update_grant_permission')
          end

          # Send verbal confirmation of access level setting.
          _event << "Permission set for user #{user.name}!"
        rescue Exception => e # TODO: Change this to show an error message instead of the stack trace.
          e.backtrace.inspect + e.message
        end
      end
    end
  end
end
