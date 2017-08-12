module RunTracker
  class RunnerCategory < JSONable

    attr_accessor :src_id,
                  :src_name,
                  :category_alias,
                  :current_pb_time,
                  :current_pb_id,
                  :milestones, # Hash of time(k) and date and runID
                  :num_previous_wrs,
                  :num_submitted_runs,
                  :total_time_overall

    # If the user is a guest, then src_id = guest and name is their name
    # TODO periodically check to see if a user has updated
    def initialize(id, name)
      self.src_id = id
      self.src_name = name
      self.category_alias = '' # TODO make a method to simplify names from their full names
      self.current_pb_time = Util::MaxInteger
      self.current_pb_id = ''
      self.milestones = Hash.new
      self.num_previous_wrs = 0
      self.num_submitted_runs = 0
      self.total_time_overall = 0
    end

  end
end
