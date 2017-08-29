module RunTracker
  class TrackedGame
    attr_accessor :id, :name, :categories, :announce_channel, :moderators

    def initialize(id, name, categories, moderators, options = {})
      self.id = id
      self.name = name
      self.categories = categories
      self.moderators = moderators
      self.announce_channel = options[:announce_channel] || 0
    end

    def fromJSON(categories, moderators)

      categories = JSON.parse(categories)
      categories.each do |key, value|
        category = Category.new(value['@category_id'], value['@category_name'], value['@rules'], value['@subcategories'])
        category.current_wr_run_id = value['@current_wr_run_id']
        category.current_wr_time = Integer(value['@current_wr_time'])
        category.longest_held_wr_time = Integer(value['@longest_held_wr_time'])
        category.longest_held_wr_id = value['@longest_held_wr_id']
        category.number_submitted_runs = Integer(value['@number_submitted_runs'])
        category.number_submitted_wrs = Integer(value['@number_submitted_wrs'])
        self.categories[key] = category
      end

      moderators = JSON.parse(moderators)
      moderators.each do |key, value|
        moderator = Moderator.new(value['@src_id'], value['@src_name'])
        moderator.discord_id = Integer(value['@discord_id'])
        moderator.should_notify = value['@should_notify'] == true
        moderator.secret_key = value['@secret_key']
        if value['@last_verified_run_date'] != nil
          moderator.last_verified_run_date = Date.strptime(value['@last_verified_run_date'], '%Y-%m-%d')
        end
        moderator.total_verified_runs = Integer(value['@total_verified_runs'])
        moderator.past_moderator = value['@past_moderator'] == true
        self.moderators[key] = moderator
      end
    end # end of fromJson
  end
end
