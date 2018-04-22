module RunTracker
  module CommandLoader
    module AddExcludeKeyword
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:addexcludekeyword, description: 'Adds a new keyword for a stream title to stop it from being announced',
                                  usage: "#{PREFIX}addexcludekeyword <keyword>",
                                  permission_level: PERM_MOD,
                                  min_args: 1,
                                  max_args: 1,
                                  bucket: :limiter) do |_event, _keyword|

        # Command Body
        newValue = ""
        begin
          # Get first row
          queryResults = SQLiteDB::Conn.execute('SELECT * FROM "settings" LIMIT 1')

          if queryResults.empty?
            newValue = _keyword
            SQLiteDB::Conn.execute('insert into "settings"
                                  ("stream_channel_id", "streamer_role", "exclude_keywords")
                                  values (?, ?, ?)',
                                  0, 0, _keyword)
          else
            newValue = queryResults.first['exclude_keywords']
            if newValue.nil?
              newValue = _keyword
            else
              newValue += "," + _keyword
            end
            SQLiteDB::Conn.execute('update "settings"
                                    set exclude_keywords = ?',
                                    newValue)
          end
        rescue SQLite3::Exception => e
          Stackdriver.exception(e)
          return
        end

        SETTINGS.exclude_keywords = newValue.split(",")
        embed = Discordrb::Webhooks::Embed.new(
            title: "Exclude Keyword Added",
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
