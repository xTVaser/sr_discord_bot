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
      List,
      Set,
      RemoveGame
    ]

    def self.getCommands
      @commands
    end

    def self.checkCommands(_command)
      @commands.each do |command|
        if _command == command
          return true
        end
      end

      return false
    end



    def self.loadCommands
      @commands.each do |command|
        RunTracker::RTBot.include!(command)
      end
    end
  end
end
