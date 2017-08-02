module RunTracker
  module Util
    # Retrives JSON given a url
    # Returns the parsed JSON object
    def self.jsonRequest(url)
      jsonURI = URI(url)
      response = Net::HTTP.get(jsonURI)

      JSON.parse(response)
    end
  end
end
