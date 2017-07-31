module RunTracker
  module CommandLoader

    # Require all command files
    Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each {
      |file| require file
    }

    @commands = [
        AddGame
    ]

    def self.loadCommands
      @commands.each do |command|
        RunTracker::RTBot.include!(command)
      end
    end
  end
end
