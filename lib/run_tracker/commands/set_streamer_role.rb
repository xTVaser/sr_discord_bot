module RunTracker
    module CommandLoader
      module SetStreamerRole
        extend Discordrb::Commands::CommandContainer
  
        # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
        bucket :limiter, limit: 1, time_span: 1, delay: 1
  
        command(:setstreamerrole, description: 'Sets the role that will be required for stream announcements.',
                                  usage: "#{PREFIX}setstreamerrole <@role>",
                                  permission_level: PERM_MOD,
                                  min_args: 1,
                                  max_args: 1,
                                  bucket: :limiter) do |_event, _role|

          # Command Body
          roleID = Integer(_role[3..-2])

          begin
            # Get first row
            queryResults = SQLiteDB::Conn.execute('SELECT * FROM "settings" LIMIT 1')

            if queryResults.empty?
                SQLiteDB::Conn.execute('insert into "settings"
                                      ("stream_channel_id", "streamer_role")
                                      values (?, ?)',
                                      0, roleID)
            else
                SQLiteDB::Conn.execute('update "settings"
                                        set streamer_role = ?',
                                        roleID)
            end
          rescue SQLite3::Exception => e
            Stackdriver.exception(e)
            return
          end

          SETTINGS.streamer_role = roleID
          embed = Discordrb::Webhooks::Embed.new(
              title: "Streamer Role Updated",
              footer: {
                text: "#{PREFIX}help to view a list of available commands"
              }
          )
          embed.colour = "#35f904"
          RTBot.send_message(_event.channel.id, "", false, embed)
  
        end # end of command body
      end # end of module
    end
  end
  