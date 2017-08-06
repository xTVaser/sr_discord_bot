module RunTracker
  module Util

    MaxInteger = 2 ** (64 - 2) - 1

    ##
    # Retrives JSON given a url
    # Returns the parsed JSON object
    def self.jsonRequest(url)
      jsonURI = URI(url)
      response = Net::HTTP.get(jsonURI)

      JSON.parse(response)
    end

    ##
    # Returns a random string with the given length
    def self.genRndStr(len)
      return (0...len).map { (65 + rand(26)).chr }.join
    end

    ##
    # Given a time in seconds, gives the next lowest minute milestone in seconds
    # For example, given 1:04:01, the next milestone would be 1:03:59
    def self.nextMilestone(time)

      # If you didnt already know, there are 60 seconds in a minute
      # Therefore we can just round down to the nearest 60 seconds - 1
      return time / 60 * 60 - 1
    end

  end
end
