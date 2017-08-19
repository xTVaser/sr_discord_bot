module RunTracker
  module CommandLoader
    # Require all command files
    Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each do |file|
      require file
    end

    # Constants
    CONST_MANAGER = 2
    CONST_MOD = 1
    CONST_USER = 0

    # Add Command module names here
    @commands = [
      AddGame,
      AddResource,
      ListCategories,
      ListGames,
      ListMods,
      Set,
      SetCategoryAlias,
      SetGameAlias,
      StatsRunner,
      RemoveGame
    ]

    def self.getCommands
      @commands
    end

    def self.checkCommands(_command)
      @commands.each do |command|
        return true if _command == command
      end

      false
    end

    def self.loadCommands
      @commands.each do |command|
        RunTracker::RTBot.include!(command)
      end
    end
  end
end
