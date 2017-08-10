module RunTracker
  module CommandLoader
    module ListFirstRow
      extend Discordrb::Commands::CommandContainer

      command(:listfirstrow, description: '',
                        usage: '',
                        min_args: 1,
                        max_args: 1) do |_event, _table| # TODO: remove this from help command

        # Command Body
        begin
          result = PostgresDB::Conn.exec("SELECT * FROM public.#{_table}").first
          rowMessage = ''
          result.each do |field|
            rowMessage += "#{field} | "
          end
          puts rowMessage # NOTE discord doesnt seem to like printing out this raw text, probably some characters it doesnt like

        rescue Exception => e
          RTBot.send_message(DevChannelID, e.backtrace.inspect + e.message) # TODO: remove stacktrace stuff
        end

        next
      end
    end
  end
end
