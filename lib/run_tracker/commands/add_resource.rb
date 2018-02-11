module RunTracker
  module CommandLoader
    module AddResource
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:addresource, description: 'Lists all categories for a specific tracked game.',
                          usage: '~addresource <gameAlias> <resource name> <content>',
                          permission_level: PERM_MOD,
                          min_args: 3,
                          max_args: 3,
                          bucket: :limiter) do |_event, _gameAlias, _name, _content|

        # Command Body
        # Check to see if alias even exists
        aliasResults = SQLiteDB::Conn.execute('SELECT * FROM "aliases" WHERE alias=? and type="game"', _gameAlias)
        if aliasResults.length < 1
          _event << "Game Alias not found use ~listgames to see the current aliases"
          return
        end

        begin
          # Set the alias for the game, and then change the prefix for any category aliases
          SQLiteDB::Conn.execute('insert into resources
                                  ("resource", 
                                  "game_alias", 
                                  "content")
                                  values (?, ?, ?)',
                                  _name,
                                  _gameAlias,
                                  _content)
        rescue SQLite3::Exception
          _event << "Already a resource for that game defined with the name `#{_name}`"
          return
        end
        embed = Discordrb::Webhooks::Embed.new(
            title: "Resource Added",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#35f904"
        RTBot.send_message(_event.channel.id, "", false, embed)

      end # end of command body
    end # end of module
  end
end
