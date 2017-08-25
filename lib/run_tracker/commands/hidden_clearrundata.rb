module RunTracker
  module CommandLoader
    module ClearRunData # TODO: change
      extend Discordrb::Commands::CommandContainer

      command(:clearruns, description: '',
                        usage: '',
                        help_available: false,
                        permission_level: PERM_ADMIN,
                        min_args: 1,
                        max_args: 1) do |_event, _confirmationCode| # TODO: config

        # Command Body
        unless _confirmationCode.casecmp("DOIT").zero?
          _event << "Enter the right confirmation code."
          next
        end

        _event << "Resetting Database"
        _event <<  PostgresDB.dontDropManagers
        _event <<  PostgresDB.generateSchema

      end # end of command body
    end
  end
end
