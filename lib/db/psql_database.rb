# On a debian distro - sudo apt-get install libpq-dev
# On another distro - ??

require 'pg'
require 'dotenv'
require 'json'

Dotenv.load('vars.env')

# Documentation at https://deveiate.org/code/pg/

module PostgresDB

  # Establish connection to PostgreSQL database
  # @@ represents a module/class variable
  @@psql = PG.connect(:url => ENV['DATABASE_URL'])

  # Called

  def self.generateSchema # No Args

  end

  def self.databaseTestSingleKey # no args

    # Simple setting of keys, can also get the value of the keys
    @@redis.set("keyTest", "Hello World")

    return "Single Key Test - keyTest:" + @@redis.get("keyTest")
  end

  def self.databaseTestJSONObject

    # Redis stores all values as strings, if we want objects,
    # we have to serialize them with ideally JSON to keep things consistent with the API
    @@redis.set("jsonTest", ["abc", "123", "ye"].to_json) # this can later be parsed as json

    return "JSON Object Test - jsonTest:" + @@redis.get("jsonTest") # JSON.parse()
  end
end
