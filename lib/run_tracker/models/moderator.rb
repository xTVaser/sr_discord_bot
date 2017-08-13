module RunTracker
  class Moderator < JSONable
    attr_accessor :src_id,
                  :src_name,
                  :discord_id,
                  :should_notify,
                  :secret_key,
                  :last_verified_run_date,
                  :total_verified_runs,
                  :past_moderator

    def initialize(id, name)
      self.src_id = id
      self.src_name = name
      self.discord_id = 0
      self.should_notify = false
      self.secret_key = Util.genRndStr(8)
      self.last_verified_run_date = nil
      self.total_verified_runs = 0
      self.past_moderator = false
    end
  end
end
