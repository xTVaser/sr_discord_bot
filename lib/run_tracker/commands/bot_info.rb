module RunTracker
  module CommandLoader
    module BotInfo
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:botinfo, description: 'Prints information on the Bot.',
                          usage: '~botinfo',
                          permission_level: PERM_USER,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 0,
                          max_args: 0) do |_event|

        # Command Body
        message = Array.new
        message.push("Source Code and Documentation - http://www.github.com/xTVaser/sr_discord_bot")
        message.push("`~help` to view available commands")
        message.push("If you do not have access to certain commands, you will need to get an admin to ~grant <admin/mod> @yourname")
        _event << Util.arrayToMessage(message)

      end # end of command body
    end # end of module
  end
end
