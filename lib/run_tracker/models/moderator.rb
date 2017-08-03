module RunTracker
  class Moderator < JSONable


    attr_accessor :src_id,
                  :src_name,
                  :discord_id,
                  :should_notify,
                  :secret_key,
                  :last_verified_run,
                  :total_verified_runs

    def initialize(id, name)
      self.src_id = id
      self.src_name = name
      self.discord_id = ''
      self.should_notify = false
      self.secret_key = Util.genRndStr(8)
      self.last_verified_run = ''
      self.total_verified_runs = ''
    end
  end
end
