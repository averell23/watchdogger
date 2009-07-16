module WatcherAction
  
  # This action posts the event to a given URL. It may use plain HTTP Authentication
  #
  # Options for this Action:
  # 
  #   url          - The URL to post the information to (required)
  #   user         - The user for HTTP Authentication (optional)
  #   pass         - The password for HTTP Authentication.
  class Htpost
    
    def initialize(options)
      @url = options.get_value(:url, false)
      @user = options.get_value(:user)
      @pass = options.get_value(:pass)
    end
    
    def execute(event)
      con_url = URI.parse(@url)
      req = Net::HTTP::Post.new(url.path)
      if(@user && @pass)
        req.basic_auth(@user, @pass)
      end
      req.set_form_data( {
        'type' => 'watchdogger_event',
        'event' => event.to_xml
      }, ';'
      )
      res = Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection:
        dog_log.debug("HTPOST Action") { "Posted event to #{@url} "}
      else
        dog_log.warn("HTPOST Action") { "Could not post to #{@url}: #{@res}"}
      end
    rescue Exception => e
      dog_log.warn("HTPOST Action") { "Error posting to #{@url}: #{e.message}"}
    end
    
  end
  
end