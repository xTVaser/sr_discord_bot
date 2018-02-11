module RunTracker
  module CommandLoader
    module BotInfo
      extend Discordrb::Commands::CommandContainer

      # Bucket for rate limiting. Limits to x uses every y seconds at z intervals.
      bucket :limiter, limit: 1, time_span: 5, delay: 1

      command(:botinfo, description: 'Prints information on the Bot.',
                          usage: "#{PREFIX}botinfo",
                          permission_level: PERM_USER,
                          rate_limit_message: 'Command Rate-Limited to Once every 5 seconds!',
                          bucket: :limiter,
                          min_args: 0,
                          max_args: 0) do |_event|

        # Command Body
        embed = Discordrb::Webhooks::Embed.new(
            author: { 
              name: "xTVaser",
              url: "https://github.com/xTVaser",
              icon_url: "https://avatars0.githubusercontent.com/u/13153231?s=460&v=4"
            },
            title: "Bot Information",
            description: "A Discord bot specializing in supporting speedrunning related discord servers.",
            url: "http://www.github.com/xTVaser/sr_discord_bot",
            footer: {
              text: "#{PREFIX}help to view a list of available commands"
            },
            thumbnail: {
              url: "https://raw.githubusercontent.com/xTVaser/sr_discord_bot/master/assets/author_icon.png"
            }
        )
        embed.colour = "#FFFFFF"
        embed.add_field(
          name: "Technical Info",
          value: "Written in Ruby with **discordrb**"
        )
        RTBot.send_message(_event.channel.id, "", false, embed)

      end # end of command body
    end # end of module
  end
end
