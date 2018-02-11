module RunTracker
  module CommandLoader
    module ClearRunData
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 1, delay: 1

      command(:clearruns, description: '',
                        usage: '',
                        help_available: false,
                        permission_level: PERM_ADMIN,
                        min_args: 1,
                        max_args: 1,
                        bucket: :limiter) do |_event, _confirmationCode|

        # Command Body
        unless _confirmationCode.casecmp("DOIT").zero?
          _event << "Enter the right confirmation code."
          next
        end

        SQLiteDB.dontDropManagers
        SQLiteDB.generateSchema

        embed = Discordrb::Webhooks::Embed.new(
            title: "Game and Run Tables Cleared",
            footer: {
              text: "~help to view a list of available commands"
            }
        )
        embed.colour = "#ff0000"
        RTBot.send_message(_event.channel.id, "", false, embed)

      end # end of command body
    end
  end
end
