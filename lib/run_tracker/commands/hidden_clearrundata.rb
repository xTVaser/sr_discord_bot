module RunTracker
  module CommandLoader
    module ClearRunData # TODO: change
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

        _event << "Resetting Database"
        _event << SQLiteDB.dontDropManagers
        _event << SQLiteDB.generateSchema

      end # end of command body
    end
  end
end
