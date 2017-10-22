module RunTracker
  module Util
    MaxInteger = 2**(64 - 2) - 1

    ##
    # Retrives JSON given a url
    # Returns the parsed JSON object
    def self.jsonRequest(url)
      pp "[JSON] #{url}"
      jsonURI = URI(url)
      response = Net::HTTP.get(jsonURI)
      response = JSON.parse(response)
      return response
    end

    ##
    # Returns a random string with the given length
    def self.genRndStr(len)
      (0...len).map { (65 + rand(26)).chr }.join
    end

    ##
    # Given a time in seconds, gives the next lowest minute milestone in seconds
    # For example, given 1:04:01, the next milestone would be 1:03:59
    def self.nextMilestone(time)
      # If you didnt already know, there are 60 seconds in a minute
      # Therefore we can just round down to the nearest 60 seconds - 1
      time / 60 * 60 - 1
    end

    ##
    # Given a time in seconds, gives the current milestone
    # For example, given 1:04:01, means Sub 1:04
    def self.currentMilestoneStr(achievedMilestone)
      achievedMilestone += 1
      minutes = achievedMilestone / 60
      hours = minutes / 60
      minutes = minutes - (hours * 60)
      return sprintf('Sub %02d:%02d', hours, minutes)
    end

    ##
    # Given the composite key for the category, return its subcategory componenets
    def self.getSubCategoryVar(key)
      subComponent = key.split('-').last.split(':')
      [subComponent.first, subComponent.last]
    end

    ##
    # Given a very long string, will split it so it is under the 5000 character limit
    # TODO make this generic by taking in the event as well
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

    ##
    # Given potentially many strings, surround them in a codeblock and return that string
    # Lines must be under 2000 characters long as that is not guaranteed here
    def self.codeBlock(*lines, highlighting: '') # This is a variadic function
      message = "```#{highlighting}\n" # Start of Code block
      lines.each do |line|
        message += "#{line}\n"
      end
      message += '```'
      message
    end # End self.codeBlock

    ##
    # Given an array of lines, do the same as self.codeBlock
    def self.arrayToCodeBlock(lines, highlighting: '') # This is a variadic function
      message = "```#{highlighting}\n" # Start of Code block
      lines.each do |line|
        message += "#{line}\n"
      end
      message += '```'
      message
    end # End self.arrayToCodeBlock

    ##
    # Given an array of lines, make a message
    def self.arrayToMessage(lines) # This is a variadic function
      message = ""
      lines.each do |line|
        message += "#{line}\n"
      end
      message
    end # End self.arrayToCodeBlock

    ##
    # Given an array of lines, make a message, guarantees character limit
    def self.safeArrayToMesage(lines, event) # This is a variadic function
      characterCount = 0
      message = ""
      lines.each do |line|
        characterCount += line.length
        if characterCount > 2000
          event.respond(message) # NOTE untested, this may not work, may have to do a hard RTBot.send_message
          characterCount = 0
          message = ""
        end
        message += "#{line}\n"
      end
      message
    end # End self.arrayToCodeBlock

    ##
    # Given seconds, turns it into time
    def self.secondsToTime(seconds)

      minutes = seconds / 60
      seconds = seconds % 60
      hours = minutes / 60
      minutes = minutes - (hours * 60)
      return sprintf('%02d:%02d:%02d', hours, minutes, seconds)
    end # end of secondsToTime
  end
end
