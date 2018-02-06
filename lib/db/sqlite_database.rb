require "sqlite3"
require 'json'

module RunTracker
  module SQLiteDB

    # Establish connection to SQLite database
    Conn = SQLite3::Database.new "db/database.db"

    # Called at this point manually to create the schema.
    # If the bot is expanded in the future, then we can either have a 'server'
    # table or create seperate DBs for each server.
    # This should be moved to a rake task rather than calling it from the bot
    # in the future
    def self.generateSchema
      # Generate tracked-games table
      createTrackedGamesCmd = 'CREATE TABLE IF NOT EXISTS "tracked_games" (' \
                              '"game_id" TEXT NOT NULL,' \
                              '"game_name" TEXT NOT NULL,' \
                              '"announce_channel" INTEGER NOT NULL,' \
                              'PRIMARY KEY ("game_id"));'
      createCategoriesCmd = 'CREATE TABLE IF NOT EXISTS categories (' \
                            '"category_id" TEXT NOT NULL,' \
                            '"game_id" TEXT NOT NULL,' \
                            'name TEXT NOT NULL,' \
                            'rules TEXT NOT NULL,' \
                            'subcategories TEXT,' \
                            'current_wr_run_id TEXT,' \
                            'current_wr_time INTEGER,' \
                            'longest_held_wr_id TEXT,' \
                            'longest_held_wr_time INTEGER,' \
                            'number_submitted_runs INTEGER,' \
                            'number_submitted_wrs INTEGER,' \
                            'PRIMARY KEY ("category_id", "game_id"));'
      createModeratorsCmd = 'CREATE TABLE IF NOT EXISTS moderators (' \
                            '"src_id" TEXT NOT NULL,' \
                            '"game_id" TEXT NOT NULL,' \
                            '"src_name" TEXT NOT NULL,' \
                            '"discord_id" INTEGER NOT NULL,' \
                            '"should_notify" INTEGER NOT NULL,' \
                            '"secret_key" TEXT NOT NULL,' \
                            '"last_verified_run_date" INTEGER,' \
                            '"total_verified_runs" INTEGER NOT NULL,' \
                            '"past_moderator" INTEGER NOT NULL,' \
                            'PRIMARY KEY ("src_id", "game_id"));'
      createTrackedRunnersCmd = 'CREATE TABLE IF NOT EXISTS "tracked_runners" (' \
                                '"user_id" TEXT NOT NULL,' \
                                '"user_name" TEXT NOT NULL,' \
                                '"historic_runs" TEXT,' \
                                '"num_submitted_wrs" INTEGER, ' \
                                '"num_submitted_runs" INTEGER, ' \
                                '"total_time_overall" INTEGER, ' \
                                'PRIMARY KEY ("user_id"));'
      createCommandPermissionsCmd = 'CREATE TABLE IF NOT EXISTS managers (' \
                                    '"user_id" TEXT NOT NULL,' \
                                    '"access_level" INTEGER NOT NULL,' \
                                    'PRIMARY KEY ("user_id"));'
      createAliasTable = 'CREATE TABLE IF NOT EXISTS aliases (' \
                         '"alias" TEXT NOT NULL,' \
                         '"type" TEXT NOT NULL,' \
                         '"id" TEXT NOT NULL UNIQUE,' \
                         'PRIMARY KEY ("alias", "type"));'
      createResourcesTable = 'CREATE TABLE IF NOT EXISTS resources (' \
                             '"resource" TEXT NOT NULL,' \
                             '"game_alias" TEXT NOT NULL,' \
                             '"content" TEXT NOT NULL,' \
                             'PRIMARY KEY ("resource", "game_alias"));'
      createNotificationTable = 'CREATE TABLE IF NOT EXISTS notifications(' \
                                '"run_id" TEXT NOT NULL,' \
                                'PRIMARY KEY ("run_id"));'
      createAnnouncementsTable = 'CREATE TABLE IF NOT EXISTS announcements(' \
                                 '"run_id" TEXT NOT NULL,' \
                                 'PRIMARY KEY ("run_id"));'
      # information tables
      Conn.execute(createTrackedGamesCmd)
      Conn.execute(createCategoriesCmd)
      Conn.execute(createModeratorsCmd)
      Conn.execute(createTrackedRunnersCmd)
      Conn.execute(createAliasTable)
      Conn.execute(createResourcesTable)
      # config tables
      Conn.execute(createCommandPermissionsCmd)
      Conn.execute(createNotificationTable)
      Conn.execute(createAnnouncementsTable)
      puts "[INFO] Tables Created Successfully"
      return 'Tables Created Succesfully'
    rescue SQLite3::Exception => e
      puts "[ERROR] #{e.message} #{e.backtrace}"
      return 'Table Creation Unsuccessful'
    end

    def self.destroySchema
      File.delete("db/database.db")
      @Conn = SQLite3::Database.new "db/database.db"
      puts "[INFO] Tables Dropped"
      return 'Schema Destroyed!'
    rescue SQLite3::Exception => e
      puts "[ERROR] #{e.message} #{e.backtrace}"
      return 'Schema Destruction Unsuccessful'
    end

    def self.dontDropManagers
      Conn.execute('DROP TABLE IF EXISTS tracked_games')
      Conn.execute('DROP TABLE IF EXISTS categories')
      Conn.execute('DROP TABLE IF EXISTS moderators')
      Conn.execute('DROP TABLE IF EXISTS tracked_runners')
      Conn.execute('DROP TABLE IF EXISTS resources')
      Conn.execute('DROP TABLE IF EXISTS aliases')
      puts "[INFO] Dropped Every Non-Manager & Notification Table"
      return 'Only Game-Related Tables Dropped!'
    end

    def self.getCurrentRunners
      runners = {}
      begin
        queryResults = Conn.execute('SELECT * FROM "tracked_runners"')
        queryResults.each do |runner|
          currentRunner = Runner.new(runner['user_id'], runner['user_name'])
          currentRunner.num_submitted_runs = Integer(runner['num_submitted_runs'])
          currentRunner.num_submitted_wrs = Integer(runner['num_submitted_wrs'])
          currentRunner.total_time_overall = Integer(runner['total_time_overall'])
          currentRunner.fromJSON(runner['historic_runs'])
          runners[(runner['user_id']).to_s] = currentRunner
        end
      rescue SQLite3::Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
      end
      return runners
    end

    def self.getCurrentRunner(runnerID)
      currentRunner = nil
      begin
        runner = Conn.execute("SELECT * FROM tracked_runners WHERE user_id = ?", runnerID).first
        if runner == nil
          return nil
        end
        currentRunner = Runner.new(runner['user_id'], runner['user_name'])
        currentRunner.num_submitted_runs = Integer(runner['num_submitted_runs'])
        currentRunner.num_submitted_wrs = Integer(runner['num_submitted_wrs'])
        currentRunner.total_time_overall = Integer(runner['total_time_overall'])
        currentRunner.fromJSON(runner['historic_runs'])
      rescue SQLite3::Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
      end
      return currentRunner
    end

    # TODO historic runs table needs to be implemented, as of right now leaving it JSON

    ##
    # Updates current runners with the new objects
    # primary key for runners is their ID field
    def self.updateCurrentRunners(currentRunners)
      # Update Statement
      currentRunners.each do |_key, runner|
        updateCurrentRunner(runner)
      end # end of loop
    end

    ##
    # Updates current runner with the new objects
    # primary key for runner is their ID field
    def self.updateCurrentRunner(runner)
      # Update Statement
      begin
        Conn.execute('update "tracked_runners"
                      set user_id = :id,
                          user_name = :name, 
                          historic_runs = :historic_runs
                          num_submitted_runs = :num_runs, 
                          num_submitted_wrs = :num_wrs, 
                          total_time_overall = :total_time, 
                      where user_id = :id',
                      :id => runner.src_id,
                      :name => runner.src_name,
                      :historic_runs => JSON.generate(runner.historic_runs),
                      :num_runs => runner.num_submitted_runs,
                      :num_wrs => runner.num_submitted_wrs,
                      :total_time => runner.total_time_overall)
      rescue SQLite3::Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
      end # end of transaction
    end # end of loop

    ##
    # Inserts brand new runners into DB
    def self.insertNewRunners(newRunners)
      # Update Statement
      newRunners.each do |_key, runner|
        insertNewRunner(runner)
      end
    end

    # TODO perhaps these should be moved into the models as static methods?

    ##
    # Inserts brand new runner into DB
    def self.insertNewRunner(runner)
      # Update Statement
      begin
        Conn.execute('insert into "tracked_runners"
                        (user_id, 
                        user_name, 
                        historic_runs, 
                        num_submitted_runs, 
                        num_submitted_wrs, 
                        total_time_overall)
                      values (?, ?, ?, ?, ?, ?)',
                      runner.src_id, 
                      runner.src_name, 
                      JSON.generate(runner.historic_runs), 
                      runner.num_submitted_runs, 
                      runner.num_submitted_wrs,
                      runner.total_time_overall)
      rescue Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
      end
    end

    ##
    # Insert new aliases into the table
    def self.insertNewAliases(newAliases)
      # Update Statement
      newAliases.each do |key, value|
        insertNewAlias(key, value)
      end
    end # end of self.insertNewAliases

    def self.insertNewAlias(key, value)
      begin
        Conn.execute('insert into "aliases"
                        (alias, 
                        type, 
                        id)
                      values (?, ?, ?)',
                      key,
                      value.first,
                      value.last)
                      # TODO unique constraint violation
      rescue SQLite3::Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
        return false
      end
      return true
    end

    def self.insertNewTrackedGame(trackedGame)
      begin
        Conn.transaction
        Conn.execute('insert into "tracked_games"
                        ("game_id", 
                        "game_name", 
                        "announce_channel")
                      values (?, ?, ?)',
                      trackedGame.id,
                      trackedGame.name,
                      trackedGame.announce_channel.id)
        categories = trackedGame.categories
        categories.each do |key, category|
          Conn.execute('insert into categories
                          ("category_id",
                          "game_id",
                          name,
                          rules,
                          subcategories,
                          "current_wr_run_id",
                          "current_wr_time",
                          "longest_held_wr_id",
                          "longest_held_wr_time",
                          "number_submitted_runs",
                          "number_submitted_wrs")
                          values (?,?,?,?,?,?,?,?,?,?,?)',
                          key,
                          trackedGame.id,
                          category.category_name,
                          category.rules,
                          category.subcategories,
                          category.current_wr_run_id,
                          category.current_wr_time,
                          category.longest_held_wr_id,
                          category.longest_held_wr_time,
                          category.number_submitted_runs,
                          category.number_submitted_wrs)
        end
        moderators = trackedGame.moderators
        moderators.each do |key, moderator|
          Conn.execute('insert into moderators
                          ("src_id",
                          "game_id",
                          "src_name",
                          "discord_id",
                          "should_notify",
                          "secret_key",
                          "last_verified_run_date",
                          "total_verified_runs",
                          "past_moderator")
                        values (?,?,?,?,?,?,?,?,?)',
                        moderator.src_id,
                        trackedGame.id,
                        moderator.src_name,
                        moderator.discord_id,
                        (moderator.should_notify ? 1 : 0),
                        moderator.secret_key,
                        moderator.last_verified_run_date.to_s, # TODO this might cause problems down the chain
                        moderator.total_verified_runs,
                        (moderator.past_moderator ? 1 : 0))
        end
        Conn.commit
      rescue SQLite3::Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
        Conn.rollback
        return false
      end
      return true
    end

    ##
    # Given an alias, return the ID equivalent
    # TODO add check on type here
    def self.findID(theAlias)
      results = Conn.execute("SELECT * FROM aliases WHERE alias=?", theAlias)
      if results.length < 1
        return nil
      end
      return results.first['id']
    end

    ##
    # Get tracked game by alias, returns object representation
    def self.getTrackedGame(game_id)
      gameResults = Conn.execute('SELECT * FROM "tracked_games" WHERE "game_id"=?', game_id)
      if gameResults.length < 1
        return nil
      end
      gameResult = gameResults.first
      game = TrackedGame.new(gameResult['game_id'], gameResult['game_name'], Hash.new, Hash.new)
      game.announce_channel = gameResult['announce_channel']
      game.fromJSON(gameResult['categories'], gameResult['moderators'])
      return game
    end

    ##
    # Get tracked games, returns object representation
    def self.getTrackedGames
      gameResults = Conn.execute("SELECT * FROM tracked_games")
      if gameResults.length < 1
        return nil
      end
      games = Array.new
      gameResults.each do |gameResult|
        game = TrackedGame.new(gameResult['game_id'], gameResult['game_name'], Hash.new, Hash.new)
        game.announce_channel = gameResult['announce_channel']
        game.fromJSON(gameResult['categories'], gameResult['moderators'])
        games.push(game)
      end
      return games
    end

    ##
    # Updates tracked game based on it's ID
    def self.updateTrackedGame(game)
      Conn.execute("update tracked_games 
                    set game_id = :id, 
                        game_name = :name,
                        announce_channel = :channel 
                    where game_id = :id",
                    :id => game.id,
                    :name => game.name,
                    :channel => game.announce_channel)
    end

    ##
    # Gets the game name alias from a category alias
    def self.categoryAliasToGameID(theAlias)
      results = Conn.execute("SELECT * FROM aliases WHERE alias=?", theAlias)
      if results.length < 1
        return nil
      end
      return self.findID(results.first['alias'].split('-').first)
    end # end of func

    ##
    # Initialize everyones permissions
    def self.initPermissions
      puts "[INFO] Initializing Permissions"
      begin
        userPermissions = Conn.execute('select * from managers') # Grab each user ID from the database
        userPermissions.each do |user|
          RTBot.set_user_permission(Integer(user['user_id']), Integer(user['access_level']))
        end
      rescue SQLite3::Exception => e
        puts "[ERROR] #{e.message} #{e.backtrace}"
      end
    end # end of func
  end # end of module
end

# TODO automate the setting up of the bot
# see if the bot can respond to it's own commands