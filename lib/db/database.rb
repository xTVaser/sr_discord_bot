require 'redis'
require 'dotenv'
require 'json'

Dotenv.load('vars.env')

# Documentation at http://github.com/redis/redis-rb

# Redis supports pipelining, atomic transactions and
# futures (aka performing an operation on a key without
# having to worry about if its there yet), see the README of redis-rb

module RedisDatabase

  # Establish connection to redis database
  # @@ represents a module/class variable
  @@redis = Redis.new(:url => ENV['REDIS_URL'])

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
