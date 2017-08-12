module RunTracker
  class RunnerGame < JSONable

    attr_accessor :src_id,
                  :src_name,
                  :categories,
                  :num_previous_wrs,
                  :num_submitted_runs,
                  :total_time_overall

    # If the user is a guest, then src_id = guest and name is their name
    # TODO periodically check to see if a user has updated
    def initialize(id, name)
      self.src_id = id
      self.src_name = name
      self.categories = Hash.new
      self.num_previous_wrs = 0
      self.num_submitted_runs = 0
      self.total_time_overall = 0
    end

  end
end
