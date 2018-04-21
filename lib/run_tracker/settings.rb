module RunTracker
    class Settings
      attr_accessor :stream_channel_id
  
      def initialize(stream_channel_id)
        self.stream_channel_id = stream_channel_id
      end
    end
  end
  