module RunTracker
    module CommandLoader
      module SetupBot
        extend Discordrb::Commands::CommandContainer
  
        # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
        bucket :limiter, limit: 1, time_span: 1, delay: 1
  
        command(:setupbot, description: '',
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
  
          _event << "Setting up Bot"
          _event << "Resetting DB"
          sleep(5)
          RTBot.commands[:resetdb].call(_event, ["DOIT"])
          _event << "Adding Games"
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["name", "jak1"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["name", "jak2"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["id", "nj1nww1p"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["name", "jakx"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["id", "m9dogm6p"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["id", "n26847dp"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["id", "n268l71p"])
          sleep(5)
          RTBot.commands[:addgame].call(_event, ["id", "2680z71p"])
          _event << "Setting Announce Channels"
          RTBot.commands[:setannounce].call(_event, ["jak1", "#jak1"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jak2", "#jak2"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jak3", "#jak3"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jakx", "#jakx"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jaktlf", "#tlf"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["daxter", "#daxter"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["trifecta", "#lobby"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jak3tjbge ", "#jak3tjbge"])
          sleep(5)
          _event << "Granting Admins"
          RTBot.commands[:setannounce].call(_event, ["@Kuitar", "admin"])
          sleep(5)
  
        end # end of command body
      end
    end
  end
  
