module RunTracker
  class TrackedGame
    attr_accessor :id, :name, :categories, :announce_channel, :moderators

    def initialize(id, name, categories, moderators, options = {})
      self.id = id
      self.name = name
      self.categories = categories
      self.moderators = moderators
      self.announce_channel = options[:announce_channel] || 0
    end
  end
end
