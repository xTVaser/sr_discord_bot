module RunTracker
  class Category < JSONable
    attr_accessor :category_id,
                  :category_name,
                  :rules,
                  :subcategories,
                  :current_wr_run_id,
                  :current_wr_time,
                  :longest_held_wr_time,
                  :longest_held_wr_id,
                  :number_submitted_runs,
                  :number_submitted_wrs

    def initialize(category_id, category_name, rules, subcategories)
      self.category_id = category_id
      self.category_name = category_name
      self.rules = rules
      self.subcategories = subcategories
      self.current_wr_run_id = ''
      self.current_wr_time = 0
      self.longest_held_wr_time = 0
      self.longest_held_wr_id = ''
      self.number_submitted_runs = 0
      self.number_submitted_wrs = 0
    end
  end
end
