module RunTracker
  class Moderator < JSONable
    attr_accessor :src_id,
                  :src_name,
                  :avatar_url,
                  :discord_id,
                  :should_notify,
                  :secret_key,
                  :last_verified_run_date,
                  :total_verified_runs,
                  :past_moderator

    def initialize(id, name)
      self.src_id = id
      self.src_name = name
      self.avatar_url = "https://www.speedrun.com/themes/user/#{self.src_name}/image.png"
      self.discord_id = 0
      self.should_notify = false
      self.secret_key = Util.genRndStr(8)
      self.last_verified_run_date = nil
      self.total_verified_runs = 0
      self.past_moderator = false
    end
  end
end
