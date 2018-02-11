module RunTracker
  module CommandLoader
    module Grant
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:grant, bucket: :limiter,
                    description: 'Allows the setting and changing of access levels for users of the server through @ mentions.',
                    usage: '~grant <@user> <permission> (permission levels: `admin`, `mod`).',
                    permission_level: PERM_ADMIN,
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
            SQLiteDB::Conn.execute('insert into "managers" 
                                    ("user_id", access_level) 
                                    values (?, ?)',
                                    user.id, level)
          rescue SQLite3::Exception 
            # Otherwise if they are already in the database we update their access level.
            SQLiteDB::Conn.execute('update "managers" 
                                    set access_level = ? 
                                    where user_id = ?',
                                    level, user.id)
          end

          # Send verbal confirmation of access level setting.
          embed = Discordrb::Webhooks::Embed.new(
              title: "Permission set for user #{user.name}",
              footer: {
                text: "~help to view a list of available commands"
              }
          )
          embed.colour = "#35f904"
          RTBot.send_message(_event.channel.id, "", false, embed)
        rescue Exception => e
          _event << "Permission failed to set: #{e.message}"
          puts "[ERROR] #{e.backtrace} + #{e.message}"
          next
        end
      end
    end
  end
end
