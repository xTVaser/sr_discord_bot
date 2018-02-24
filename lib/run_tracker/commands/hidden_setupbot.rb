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
          RTBot.send_message(_event.channel.id, "Gotcha")
          sleep(5)
          RTBot.send_message(_event.channel.id, "Setting up Bot")
          RTBot.send_message(_event.channel.id, "Resetting DB")
          RTBot.commands[:clearruns].call(_event, ["DOIT"])
          RTBot.send_message(_event.channel.id, "Adding Games")
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
          sleep(5)
          RTBot.send_message(_event.channel.id, "Setting Announce Channels")
          RTBot.commands[:setannounce].call(_event, ["jak1", "<#183602484621606912>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jak2", "<#183602500375543808>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jak3", "<#183602510517239808>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jakx", "<#183602636623314944>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jaktlf", "<#208413083218083841>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["daxter", "<#160428665069502464>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["trifecta", "<#83031186590400512>"])
          sleep(5)
          RTBot.commands[:setannounce].call(_event, ["jak3tjbge", "<#276472462001307648>"])
          sleep(5)
          RTBot.send_message(_event.channel.id, "Granting Admins")
          RTBot.commands[:grant].call(_event, ["<@83571817779822592>", "admin"])
          sleep(5)
          RTBot.commands[:grant].call(_event, ["<@115998281317875714>", "admin"])
  
        end # end of command body
      end
    end
  end
  
