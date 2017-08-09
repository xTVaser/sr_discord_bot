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

    ##
    # Given the composite key for the category, return its subcategory componenets
    def self.getSubCategoryVar(key)
      subComponent = key.split('-').last
      return [subComponent.first, subComponent.last]
    end

    ##
    #
    def self.sendBulkMessage(message)
      if message.length <= 5000
        RTBot.send_message(DevChannelID, message)
      else
        multipleMessages = message.scan(/.{1,5000}/) # divides into strings every 5000characters
        multipleMessages.each do |msg|
          RTBot.send_message(DevChannelID, msg)
        end
      end
    end

  end
end
