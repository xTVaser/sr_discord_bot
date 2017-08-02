module RunTracker
  module CommandLoader
    # Require all command files
    Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each do |file|
      require file
    end

    # Add Command module names here
    @commands = [
      AddGame,
      List,
      Set
    ]

    def self.loadCommands
      @commands.each do |command|
        RunTracker::RTBot.include!(command)
      end
    end
  end
end
