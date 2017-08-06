module RunTracker
  module CommandLoader
    module ListTable
      extend Discordrb::Commands::CommandContainer

      command(:listtable, description: '',
                        usage: '',
                        min_args: 1,
                        max_args: 1) do |_event, _table| # TODO: remove this from help command

        # Command Body
        results = PostgresDB::Conn.exec("SELECT * FROM public.#{_table}")
        fields = results.fields
        RTBot.send_message(DevChannelID, "#{results.ntuples} rows found in #{_table}")
        count = 0
        results.each do |row|
          rowMessage = ''
          fields.each do |field|
            rowMessage += "#{row[field]} | "
          end
          RTBot.send_message(DevChannelID, "#{count} - #{rowMessage}")
          count += 1
        end

        next
      end
    end
  end
end
