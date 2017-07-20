require "sr_discord_bot/version"

#  All code in the gem is namespaced under this class.
class DiscordBot
  def initialize(name)
    @name = name.capitalize
  end
  def sayHi
    return "Hello #{@name}"
  end
end
