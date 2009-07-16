require 'logger'

module WatcherAction
  
  # Logs the event information to the standard log file
  # Options:
  #
  #  format - A format string that will receive the timestamp, watcher name and 
  #           event message (in that order) as parameters (default message if not given)
  #  severity - The severity of the log message (default: warn)
  class LogAction
    
    def initialize(options)
      @format = options.get_value(:format, "Watcher %s triggered at %s: %s")
      if(severity = options.get_value(:severity))
        @severity = Logger.const_get(severity.upcase)
      else
        @severity = Logger::WARN
      end
    end
    
    def execute(event)
      dog_log.add(@severity, nil, 'LoggerAction') { @format % [event.watcher, event.timestamp, event.message] }
    end
    
  end
end