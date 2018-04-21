module RunTracker
    module CommandLoader
      module SetStreamChannel
        extend Discordrb::Commands::CommandContainer
  
        # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
        bucket :limiter, limit: 1, time_span: 1, delay: 1
  
        command(:setstreamchannel, description: 'Sets the channel that will be used for stream announcements.',
                                   usage: "#{PREFIX}setstreamchannel <#channel>",
                                   permission_level: PERM_MOD,
                                   min_args: 1,
                                   max_args: 1,
                                   bucket: :limiter) do |_event, _channel|

          # Command Body
          channelID = Integer(_channel[2..-2])
          begin
            # Get first row
            queryResults = SQLiteDB::Conn.execute('SELECT * FROM "settings" LIMIT 1')

            if queryResults.empty?
                SQLiteDB::Conn.execute('insert into "settings"
                                      ("stream_channel_id")
                                      values (?)',
                                      channelID)
            else
                SQLiteDB::Conn.execute('update "settings"
                                        set stream_channel_id = ? 
                                        where stream_channel_id = ?',
                                        channelID,
                                        queryResults.first['stream_channel_id'])
            end
          rescue SQLite3::Exception => e
            Stackdriver.exception(e)
            return
          end

          SETTINGS.stream_channel_id = channelID
          embed = Discordrb::Webhooks::Embed.new(
              title: "Stream Channel Updated",
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
  