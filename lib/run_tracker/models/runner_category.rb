module RunTracker
  class RunnerCategory < JSONable

    attr_accessor :src_id,
                  :src_name,
                  :category_alias,
                  :milestones, # Hash of time(k) and date and runID
                  :num_previous_wrs,
                  :num_submitted_runs,
                  :total_time_overall

    # If the user is a guest, then src_id = guest and name is their name
    # TODO periodically check to see if a user has updated
    def initialize(id, name, category_alias)
      self.src_id = id
      self.src_name = name
    end

  end
end
