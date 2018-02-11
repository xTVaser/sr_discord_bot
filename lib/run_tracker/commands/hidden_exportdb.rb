module RunTracker
    module CommandLoader
      module ExportDB
        extend Discordrb::Commands::CommandContainer
  
        # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
        bucket :limiter, limit: 1, time_span: 1, delay: 1
  
        command(:exportdb, description: '',
                          usage: '',
                          help_available: false,
                          permission_level: PERM_ADMIN,
                          min_args: 0,
                          max_args: 0,
                          bucket: :limiter) do |_event|
  
            # Command Body
            # Split and Compress the Database
            # TODO get this working on both windows and linux after
            # this is only needed to bypass the 8mb / attachment limit
            # system 'cp db/database.db database.db'
            # ok = system '7z -v5m a exported_db.7z database.db'
            # system 'rm database.db'
            RTBot.send_file(_event.channel.id, File.open('db/database.db', 'r'))
        end # end of command body
      end
    end
  end
  
