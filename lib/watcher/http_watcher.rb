require 'net/http'

module Watcher
  
  # Checks an http connection if it is active and returns the expected results.
  # Options for this watcher:
  # 
  #   url           - The URL to query (required)
  #   response      - The response code that is expected from the operation
  #   content_match - A regular expression that is matched against the result.
  #                   The watcher fails if the expression doesn't match
  #   timeout       - The timeout for the connection attempt. Defaults to 10 sec
  # 
  # If neither response nor content_match are given, the watcher will expect a 
  # 200 OK response from the server.
  #
  # This watcher resets the current severity on each successful connect, so that
  # only continuous failures count against the trigger condition.
  class HttpWatcher < Watcher::Base
    
    def initialize(config)
      @url = config.get_value(:url, false)
      match = config.get_value(:content_match)
      @content_match = Regexp.new(match) if(match)
      response = config.get_value(:response)
      @response = ((!response && !match) ? "200" : response)
      @timeout = config.get_value(:timeout, 10).to_i
    end
    
    def watch_it!
      url = URI.parse(@url)
      res = Net::HTTP.start(url.host, url.port) do |http| 
        http.read_timeout = @timeout
        http.get(url.path) 
      end
      test_failed = false
      if(@response && (@response.to_s != res.code))
        test_failed = "Unexpected HTTP response: #{res.code} for #{@url} - expected #{@response}"
      elsif(@content_match && !@content_match.match(res.body))
        test_failed = "Did not find #{@content_match.to_s} at #{@url}"
      end
      @current_severity = 0 unless(test_failed)
      dog_log.debug('HttpWatcher') { "Watch of #{@url} resulted in #{test_failed}" }
      test_failed
    rescue Exception => e
      dog_log.debug('HttpWatcher') { "Watch of #{@url} had exception #{e.message}"}
      "Exception on connect to #{@url} - #{e.message}"
    end
    
  end
  
end