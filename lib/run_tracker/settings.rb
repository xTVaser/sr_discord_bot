module RunTracker
  class Settings
    attr_accessor :allowed_game_list,
                  :debug_channel_id,
                  :stream_channel_id,
                  :streamer_role,
                  :exclude_keywords
    def initialize(stream_channel_id)
      self.allowed_game_list = ""
      self.debug_channel_id = stream_channel_id
      self.stream_channel_id = stream_channel_id
      self.streamer_role = 0
      self.exclude_keywords = Array.new
    end
  end
end
