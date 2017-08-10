module RunTracker
  class Runner < JSONable

    attr_accessor :src_id,
                  :src_name,
                  :historic_runs,
                  :num_submitted_wrs,
                  :num_submitted_runs,
                  :total_time_overall

    # If the user is a guest, then src_id = guest and name is their name
    # TODO periodically check to see if a user has updated
    def initialize(id, name)
      self.src_id = id
      self.src_name = name
      self.historic_runs = Hash.new
      self.num_submitted_wrs = 0
      self.num_submitted_runs = 0
      self.total_time_overall = 0
    end

  end
end
