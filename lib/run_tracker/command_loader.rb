module RunTracker
  module CommandLoader
    # Require all command files
    Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each do |file|
      require file
    end

    # Add Command module names here
    @commands = [
      AddGame,
      AddResource,
      BotInfo,
      ClearRunData,
      ExportDB,
      ListCategories,
      ListGames,
      ListResources,
      ListMods,
      Grant,
      OptIn,
      OptOut,
      SetAnnounce,
      SetCategoryAlias,
      SetGameAlias,
      SetupBot,
      StatsCategory,
      StatsGame,
      StatsRunner,
      RemoveGame,
      RemoveResource,
      ResetDB,
      Resource
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
