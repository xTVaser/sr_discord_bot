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
                              '"game_alias" character varying(255) NOT NULL,' \
                              '"game_name" text NOT NULL,' \
                              '"announce_channel" character varying(255) NOT NULL,' \
                              'categories jsonb,' \
                              'moderators jsonb,' \
                              'PRIMARY KEY ("game_id"))' \
                              'WITH (' \
                              'OIDS = FALSE);'
      createTrackedRunnersCmd = 'CREATE TABLE IF NOT EXISTS public."tracked_runners"(' \
                                '"user_id" character varying(255) NOT NULL,' \
                                '"user_name" character varying(255) NOT NULL,' \
                                '"current_personal_bests" jsonb,' \
                                '"historic_runs" jsonb,' \
                                'PRIMARY KEY ("user_id"))' \
                                'WITH (' \
                                'OIDS = FALSE);'
      createCommandPermissionsCmd = 'CREATE TABLE IF NOT EXISTS public."managers"(' \
                                    '"user_id" character varying(255) NOT NULL,' \
                                    '"access_level" integer NOT NULL,' \
                                    'PRIMARY KEY ("user_id"))' \
                                    'WITH (' \
                                    'OIDS = FALSE);'
      Conn.exec(createTrackedGamesCmd)
      Conn.exec(createTrackedRunnersCmd)
      Conn.exec(createCommandPermissionsCmd)
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

    # TODO might not fully parse JSON?
    def self.getCurrentRunners()
      runners = Hash.new
      queryResults = PostgresDB::Conn.exec('SELECT * FROM public."tracked_runners"')

      queryResults.each do |runner|
        runners["#{runner.user_id}"] = runner # might have to do more than this
      end
      return runners
    end
    
  end
end
