module RunTracker
    module CommandLoader
      module SetAllowedGameList
        extend Discordrb::Commands::CommandContainer
  
        # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
        bucket :limiter, limit: 1, time_span: 1, delay: 1
  
        command(:setstreamchannel, description: 'Sets the allowed list of games that should be announced, comma separated, must match the game name on Twitch.',
                                   usage: "#{PREFIX}setallowedgamelist <#channel>",
                                   permission_level: PERM_MOD,
                                   min_args: 1,
                                   max_args: 1,
                                   bucket: :limiter) do |_event, _list|

          # Command Body
          gameList = _list
          begin
            # Get first row
            queryResults = SQLiteDB::Conn.execute('SELECT * FROM "settings" LIMIT 1')

            if queryResults.empty?
                SQLiteDB::Conn.execute('insert into "settings"
                                      ("allowed_game_list")
                                      values (?)',
                                      gameList)
            else
                SQLiteDB::Conn.execute('update "settings"
                                        set allowed_game_list = ?',
                                        gameList)
            end
          rescue SQLite3::Exception => e
            Stackdriver.exception(e)
            return
          end

          SETTINGS.allowed_game_list = gameList.split(",")
          embed = Discordrb::Webhooks::Embed.new(
              title: "Allowed Game List Updated",
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
  