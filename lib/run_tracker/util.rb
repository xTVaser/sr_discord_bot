module RunTracker
  module Util
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

  end
end
