# On a debian distro - sudo apt-get install libpq-dev
# On another distro - ??

require 'pg'
require 'dotenv'
require 'json'

Dotenv.load('vars.env')

# Documentation at https://deveiate.org/code/pg/
# GUI for postgreSQL run `docker run --rm -p 5050:5050 thajeztah/pgadmin4`

module PostgresDB
  # Format of ENV Variable is:
  # user:password@host:port/dbname
  databaseParams = ENV['DATABASE_URL'].sub("postgres://", "")
  databaseParams = databaseParams.split(":")

  username = databaseParams.first
  password = databaseParams[1].split("@").first
  host = databaseParams[1].split("@").last
  port = databaseParams[2].split("/").first
  dbname = databaseParams[2].split("/").last


  # Establish connection to PostgreSQL database
  # @@ represents a module/class variable
  @@psql = PG.connect(:user => username,
                      :password => password,
                      :host => host,
                      :port => port,
                      :dbname => dbname)

  # Called at this point manually to create the schema.
  # If the bot is expanded in the future, then we can either have a 'server'
  # table or create seperate DBs for each server.
  # This should be moved to a rake task rather than calling it from the bot
  # in the future
  def self.generateSchema
    # Generate tracked-games table
    begin
      createTrackedGamesCmd = "CREATE TABLE IF NOT EXISTS public.\"tracked-games\" (" +
                                "\"game-id\" character varying(255) NOT NULL," +
                                "categories jsonb," +
                                "moderators jsonb," +
                                "PRIMARY KEY (\"game-id\"))" +
                              "WITH (" +
                                "OIDS = FALSE);"
      createTrackedRunnersCmd = "CREATE TABLE IF NOT EXISTS public.\"tracked-runners\"(" +
                                  "\"user-id\" character varying(255) NOT NULL," +
                                  "\"current-personal-bests\" jsonb," +
                                  "\"historic-runs\" jsonb," +
                                  "PRIMARY KEY (\"user-id\"))" +
                                "WITH (" +
                                  "OIDS = FALSE);"
      createCommandPermissionsCmd = "CREATE TABLE IF NOT EXISTS public.\"managers\"(" +
                                      "\"user-id\" character varying(255) NOT NULL," +
                                      "\"access-level\" integer," +
                                      "PRIMARY KEY (\"user-id\"))" +
                                    "WITH (" +
                                      "OIDS = FALSE);"
    @@psql.exec(createTrackedGamesCmd)
    @@psql.exec(createTrackedRunnersCmd)
    @@psql.exec(createCommandPermissionsCmd)
    return "Tables Created Succesfully"
    rescue PG::Error => e
      return "Table Creation Unsuccessful: " + e.message
    end
  end
end
