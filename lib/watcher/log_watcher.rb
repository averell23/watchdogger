require 'file/tail'

module Watcher
  
  # Watches a log file for a given regular expression. This watcher will start a background thread that 
  # tails the log and matches against the regexp.
  #
  # The current implementation is not tested against logs with very high load.
  # 
  # = Options
  # 
  # [*logfile*] The log file to watch (required)
  # [*match*] A regular expression against which the log file will be matched (required)
  # [*interval_first, interval_max*] The start and the max value for waiting on an unchanged
  #                                  log file. They default to 60 (1 minute) and 300 (5 minutes). 
  #                                  The log file will be considered stale and reopened after max_value * 3.
  #
  # = Warning
  # 
  # Depending on your Ruby implementation and platform, the background thread may not be
  # taken down if Watchdogger explodes during runtime.
  #
  # On a clean exit, all threads will be cleanly shut down, but if you kill -9 it,
  # you may want to check for any rogue processes.
  class LogWatcher < Watcher::Base
    
    def initialize(options)
       @file_name = options.get_value(:logfile, false)
       @match_str = options.get_value(:match, false)
      
       @interval_first = options.get_value(:interval_first, 60).to_i
       @interval_max = options.get_value(:interval_max, 300).to_i
      
       watch_log # Start the watcher
    end
    
    def watch_it!
      unless(@log_watcher.status) # Restart the watcher if killed for some reason
        dog_log.warn { "Log watcher on #{@file_name} died? Restarting..." }
        watch_log
      end
      is_triggered = false
      if(triggered?)
        is_triggered = "Found #{@match_str} in #{@file_name}"
      end
      is_triggered
    rescue Exception => e
      "Exception running the log watcher: #{e}"
    end
    
    def cleanup
      @log_watcher.kill if(@log_watcher && !@log_watcher.stop?)
    end
    
    private
    
    def triggered?
      @triggered
    end
    
    def triggered!
      @my_mutex.synchronize { @triggered = true }
    end
    
    def reset_trigger
      @my_mutex.synchronize { @triggered = false }
    end
    
    def watch_log
      @my_mutex = Mutex.new
      if(@log_watcher)
        dog_log.warn { "Existing log watcher on #{@file_name}, killing."}
        @log_watcher.terminate! 
      end
      @log_watcher = Thread.new(@match_str, @file_name) do |match_str, file_name|
        matcher = Regexp.new(match_str) 
        logfile = File::Tail::Logfile.open(file_name, 
          :backward => 1,
          :reopen_deleted => true,
          :interval => @interval_first,
          :max_interval => @interval_max,
          :reopen_suspicious => true,
          :suspicious_interval => (@interval_max * 3)
        )
        logfile.tail do |line|
          if(matcher.match(line))
            triggered!
          end
        end
      end
      dog_log.debug { "Log watcher thread started for #{@file_name}" }
    end
    
  end
end