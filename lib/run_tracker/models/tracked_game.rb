module RunTracker
  class TrackedGame
    attr_accessor :id, 
                  :name,
                  :cover_url, 
                  :categories, 
                  :announce_channel, 
                  :moderators

    def initialize(id, name, cover_url, categories, moderators, options = {})
      self.id = id
      self.name = name
      self.cover_url = cover_url
      self.categories = categories
      self.moderators = moderators
      self.announce_channel = options[:announce_channel] || 0
    end
  end
end
