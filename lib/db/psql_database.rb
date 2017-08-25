# On a debian distro - sudo apt-get install libpq-dev
# On another distro - ??

require 'pg'
require 'dotenv'
require 'json'

Dotenv.load('vars.env')

# Documentation at https://deveiate.org/code/pg/
# GUI for postgreSQL run `docker run --rm -p 5050:5050 thajeztah/pgadmin4`
module RunTracker
  module PostgresDB
    # Format of ENV Variable is:
    # user:password@host:port/dbname
    databaseParams = ENV['DATABASE_URL'].sub('postgres://', '')
    databaseParams = databaseParams.split(':')

    username = databaseParams.first
    password = databaseParams[1].split('@').first
    host = databaseParams[1].split('@').last
    port = databaseParams[2].split('/').first
    dbname = databaseParams[2].split('/').last

    # Establish connection to PostgreSQL database
    Conn = PG.connect(user: username,
                      password: password,
                      host: host,
                      port: port,
                      dbname: dbname)

    # Called at this point manually to create the schema.
    # If the bot is expanded in the future, then we can either have a 'server'
    # table or create seperate DBs for each server.
    # This should be moved to a rake task rather than calling it from the bot
    # in the future
    def self.generateSchema
      # Generate tracked-games table

      createTrackedGamesCmd = 'CREATE TABLE IF NOT EXISTS public."tracked_games" (' \
                              '"game_id" character varying(255) NOT NULL,' \
                              '"game_name" text NOT NULL,' \
                              '"announce_channel" bigint NOT NULL,' \
                              'categories jsonb,' \
                              'moderators jsonb,' \
                              'PRIMARY KEY ("game_id"))' \
                              'WITH (' \
                              'OIDS = FALSE);'
      createTrackedRunnersCmd = 'CREATE TABLE IF NOT EXISTS public."tracked_runners"(' \
                                '"user_id" character varying(255) NOT NULL,' \
                                '"user_name" character varying(255) NOT NULL,' \
                                '"historic_runs" jsonb,' \
                                '"num_submitted_wrs" integer, ' \
                                '"num_submitted_runs" integer, ' \
                                '"total_time_overall" bigint, ' \
                                'PRIMARY KEY ("user_id"))' \
                                'WITH (' \
                                'OIDS = FALSE);'
      createCommandPermissionsCmd = 'CREATE TABLE IF NOT EXISTS public."managers"(' \
                                    '"user_id" character varying(255) NOT NULL,' \
                                    '"access_level" integer NOT NULL,' \
                                    'PRIMARY KEY ("user_id"))' \
                                    'WITH (' \
                                    'OIDS = FALSE);'
      createAliasTable = 'CREATE TABLE IF NOT EXISTS public."aliases"(' \
                         '"alias" character varying(255) NOT NULL,' \
                         '"type" character varying(255) NOT NULL,' \
                         '"id" character varying(255) NOT NULL UNIQUE,' \
                         'PRIMARY KEY ("alias"))' \
                         'WITH (' \
                         'OIDS = FALSE);'
      createResourcesTable = 'CREATE TABLE IF NOT EXISTS public.resources(' \
                             '"resource" character varying(255) NOT NULL,' \
                             '"game_alias" character varying(255) NOT NULL,' \
                             '"content" text NOT NULL,' \
                             'PRIMARY KEY ("resource", "game_alias"))' \
                             'WITH (' \
                             'OIDS = FALSE);'
      createNotificationTable = 'CREATE TABLE IF NOT EXISTS public.notifications(' \
                             '"run_id" character varying(255) NOT NULL,' \
                             '"count" SERIAL,' \
                             'PRIMARY KEY ("run_id"))' \
                             'WITH (' \
                             'OIDS = FALSE);'

      Conn.exec(createTrackedGamesCmd)
      Conn.exec(createTrackedRunnersCmd)
      Conn.exec(createCommandPermissionsCmd)
      Conn.exec(createAliasTable)
      Conn.exec(createResourcesTable)
      Conn.exec(createNotificationTable)
      return 'Tables Created Succesfully'
    rescue PG::Error => e
      return 'Table Creation Unsuccessful: ' + e.message
    end

    def self.destroySchema
      Conn.exec('DROP SCHEMA public CASCADE;')
      Conn.exec('CREATE SCHEMA public;')
      return 'Schema Destroyed!'
    rescue PG::Error => e
      return 'Schema Destruction Unsuccessful: ' + e.message
    end

    def self.dontDropManagers
      Conn.exec('DROP TABLE IF EXISTS public.tracked_games')
      Conn.exec('DROP TABLE IF EXISTS public.tracked_runners')
      Conn.exec('DROP TABLE IF EXISTS public.resources')
      Conn.exec('DROP TABLE IF EXISTS public.aliases')
    end

    def self.cleanNotificationTable

      # Pull all the rows
      rows = Conn.exec("SELECT * FROM public.notifications ORDER BY count DESC")
      if rows.ntuples < 200
        return
      end
      # Get the highest count, subtract 25
      cutoff = (rows.first.count) - 25
      # Delete the other 150 rows
      Conn.exec("DELETE FROM public.notifications WHERE count < '#{cutoff}'")

    end

    def self.getCurrentRunners

      runners = {}

      PostgresDB::Conn.transaction do |conn|

        queryResults = conn.exec('SELECT * FROM public."tracked_runners"')

        queryResults.each do |runner|
          currentRunner = Runner.new(runner['user_id'], runner['user_name'])
          currentRunner.num_submitted_runs = Integer(runner['num_submitted_runs'])
          currentRunner.num_submitted_wrs = Integer(runner['num_submitted_wrs'])
          currentRunner.total_time_overall = Integer(runner['total_time_overall'])
          currentRunner.fromJSON(runner['historic_runs'])
          runners[(runner['user_id']).to_s] = currentRunner
        end
      end
      runners
    end

    ##
    # Updates current runners with the new objects
    # primary key for runners is their ID field
    def self.updateCurrentRunners(currentRunners)
      # Update Statement
      PostgresDB::Conn.prepare('update_current_runner', 'update public."tracked_runners"
        set user_id = $1, user_name = $2, historic_runs = $3, num_submitted_runs = $4, num_submitted_wrs = $5, total_time_overall = $6
        where user_id = $1')
      currentRunners.each do |_key, runner|
        begin
          PostgresDB::Conn.exec_prepared('update_current_runner', [runner.src_id, runner.src_name,
                                                                   JSON.generate(runner.historic_runs), runner.num_submitted_runs,
                                                                   runner.num_submitted_wrs, runner.total_time_overall])
        rescue Exception => e
          puts "#{e.message} #{e.backtrace}"
        end
      end
      PostgresDB::Conn.exec('DEALLOCATE update_current_runner')
    end

    ##
    # Inserts brand new runners into DB
    def self.insertNewRunners(newRunners)
      # Update Statement
      PostgresDB::Conn.prepare('insert_new_runner', 'insert into public."tracked_runners"
        (user_id, user_name, historic_runs, num_submitted_runs, num_submitted_wrs, total_time_overall)
        values ($1, $2, $3, $4, $5, $6)')
      newRunners.each do |_key, runner|
        begin
          PostgresDB::Conn.exec_prepared('insert_new_runner', [runner.src_id, runner.src_name,
                                                               JSON.generate(runner.historic_runs), runner.num_submitted_runs,
                                                               runner.num_submitted_wrs, runner.total_time_overall])
        rescue Exception => e
          puts "#{e.message} #{e.backtrace}"
        end
      end
      PostgresDB::Conn.exec('DEALLOCATE insert_new_runner')
    end

    ##
    # Insert new aliases into the table
    def self.insertNewAliases(newAliases)
      # Update Statement
      PostgresDB::Conn.prepare('insert_new_alias', 'insert into public."aliases"
                               (alias, type, id)
                               values ($1, $2, $3)')
      newAliases.each do |key, value|
        begin
          PostgresDB::Conn.exec_prepared('insert_new_alias', [key, value.first, value.last])
        rescue Exception => e
          puts "#{e.message} #{e.backtrace}"
        end
      end
      PostgresDB::Conn.exec('DEALLOCATE insert_new_alias')
    end # end of self.insertNewAliases

    ##
    # Given an alias, return the ID equivalent
    # TODO add check on type here
    def self.findID(theAlias)

      PostgresDB::Conn.prepare('find_alias', "SELECT * FROM public.aliases WHERE alias=$1")
      results = PostgresDB::Conn.exec_prepared('find_alias', [theAlias])
      PostgresDB::Conn.exec('DEALLOCATE find_alias')

      if results.ntuples < 1
        return nil
      end
      return results.first['id']
    end

    ##
    # Get tracked game by alias, returns object representation
    def self.getTrackedGame(game_id)
      gameResults = PostgresDB::Conn.exec("SELECT * FROM public.\"tracked_games\" WHERE \"game_id\"='#{game_id}'")
      if gameResults.ntuples < 1
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
      gameResults = PostgresDB::Conn.exec("SELECT * FROM public.tracked_games")
      if gameResults.ntuples < 1
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
      PostgresDB::Conn.prepare('update_tracked_game', "update public.tracked_games set game_id = $1, game_name = $2,
                                announce_channel = $3, categories = $4, moderators = $5 where game_id = $1")
      PostgresDB::Conn.exec_prepared('update_tracked_game', [game.id, game.name, game.announce_channel,
                                                             JSON.generate(game.categories),
                                                             JSON.generate(game.moderators)])
      PostgresDB::Conn.exec('DEALLOCATE update_tracked_game')
    end

    ##
    # Gets the game name alias from a category alias
    def self.categoryAliasToGameID(theAlias)

      PostgresDB::Conn.prepare('find_alias', "SELECT * FROM public.aliases WHERE alias=$1")
      results = PostgresDB::Conn.exec_prepared('find_alias', [theAlias])
      PostgresDB::Conn.exec('DEALLOCATE find_alias')

      if results.ntuples < 1
        return nil
      end
      return self.findID(results.first['alias'].split('-').first)
    end # end of func

    ##
    # Initialize everyones permissions
    def self.initPermissions
      begin
        userPermissions = PostgresDB::Conn.exec('select * from public.managers') # Grab each user ID from the database
        userPermissions.each do |user|
          RTBot.set_user_permission(Integer(user['user_id']), Integer(user['access_level']))
        end
      rescue Exception => e
        _event << e.backtrace.inspect + e.message + "lol sick spam"
      end
    end # end of func

  end # end of module
end
