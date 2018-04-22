module RunTracker
    class Settings
      attr_accessor :stream_channel_id,
                    :streamer_role,
                    :exclude_keywords
  
      def initialize(stream_channel_id)
        self.stream_channel_id = stream_channel_id
        self.streamer_role = 0
        self.exclude_keywords = Array.new
      end
    end
  end
  