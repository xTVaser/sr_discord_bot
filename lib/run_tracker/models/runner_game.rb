module RunTracker
  class RunnerGame < JSONable

    attr_accessor :src_id,
                  :src_name,
                  :game_alias,
                  :categories,
                  :num_previous_wrs,
                  :num_submitted_runs,
                  :total_time_overall

    # If the user is a guest, then src_id = guest and name is their name
    # TODO periodically check to see if a user has updated
    def initialize(id, name, game_alias)
      self.src_id = id
      self.src_name = name
      self.game_alias = game_alias
    end

  end
end
