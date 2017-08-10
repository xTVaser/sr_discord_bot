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
      self.historic_runs = Hash.new # Game > Categories
      self.num_submitted_wrs = 0
      self.num_submitted_runs = 0
      self.total_time_overall = 0
    end

    def fromJSON(games)

      games = JSON.parse(games)

      games.each do |key, value|

        runnerGame = RunnerGame.new(value['@src_id'], value['@src_name'], value['@game_alias'])
        runnerGame.num_previous_wrs = Integer(value['@num_previous_wrs'])
        runnerGame.num_submitted_runs = Integer(value['@num_submitted_runs'])
        runnerGame.total_time_overall = Integer(value['@total_time_overall'])

        value['@categories'].each do |catKey, catValue|

          category = RunnerCategory.new(catValue['@src_id'], catValue['@src_name'])
          category.current_pb_id = catValue['@current_pb_id']
          category.current_pb_time = Integer(catValue['@current_pb_time'])
          category.category_alias = catValue['@category_alias']
          category.num_previous_wrs = Integer(catValue['@num_previous_wrs'])
          category.num_submitted_runs = Integer(catValue['@num_submitted_runs'])
          category.total_time_overall = Integer(catValue['@total_time_overall'])

          catValue['@milestones'].each do |mileKey, mileValue|
            category.milestones[mileKey] = mileValue
          end

          runnerGame.categories[catKey] = category
        end

        self.historic_runs[key] = runnerGame
      end
    end

  end
end
