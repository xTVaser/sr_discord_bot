module RunTracker
  class TrackedGame

    def initialize (id, game_alias, channel, categories, moderators)
      @game_id = id
      @game_alias = game_alias
      @announce_channel = channel
      @categories = categories
      @moderators = moderators
    end

  end
end
