module RunTracker
  class Runner < JSONable

    attr_accessor :src_id,
                  :src_name,
                  :historic_runs,
                  :num_submitted_runs,
                  :total_time_overall

    # If the user is a guest, then src_id = guest and name is their name
    # TODO periodically check to see if a user has updated
    def initialize(id, name)
      self.src_id = id
      self.src_name = name
    end

  end
end
