module RunTracker
  class TrackedGame
    attr_accessor :id, :name, :categories, :game_alias, :announce_channel, :moderators

    def initialize(id, name, categories, moderators, options = {})
      self.id = id
      self.name = name
      self.categories = categories
      self.moderators = moderators
      self.game_alias = options[:game_alias] || ''
      self.announce_channel = options[:announce_channel] || 0
    end
  end
end
