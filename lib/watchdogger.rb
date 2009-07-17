require 'rubygems'
require 'optiflag'
require 'etc'
require 'yaml'
require 'assit'

# require our own stuff
lib_dir = File.expand_path(File.dirname(__FILE__)) 
$: << lib_dir
require 'dog_log'
require 'watcher'
require 'watcher_action'
require 'watcher_event'

# Require the Watcher
Dir[File.join(lib_dir, 'watcher', '*.rb')].each { |f| require 'watcher/' + File.basename(f, '.rb') }
# Require the actions
Dir[File.join(lib_dir, 'watcher_action', '*.rb')].each { |f| require 'watcher_action/' + File.basename(f, '.rb') }

module WatchDogger # :nodoc:
  
  class << self
    
    # Initializes the watchdog system, sets up the log. In addition to the configured
    # Watchers and WatcherActions, the system can take the following arguments:
    #
    #  [*log_level*] The log level for the system log. This will apply to all log messages
    #  [*logfile*] The log file for the system. Defaults to STDOUT
    #  [*interval*] The watch interval in seconds. Defaults to 60
    def init_system(options)
      # First setup the logging options
      @log_level = options.get_value(:log_level)
      @logfile = options.get_value(:logfile)
      DogLog.setup(@logfile, @log_level)
      
      # Now setup the actions
      actions = options.get_value(:actions, false)
      raise(ArgumentError, "Actions not configured correctly.") unless(actions.is_a?(Hash))
      actions.each do |act_name, act_options|
        WatcherAction.register(act_name, act_options)
      end
      
      # Setupup the watchers
      watchers = options.get_value(:watchers, false)
      raise(ArgumentError, "Watchers not configured correctly.") unless(watchers.is_a?(Hash))
      watchers.each do |watch_name, watch_options|
        Watcher.register(watch_name, watch_options)
      end
      
      dog_log.info('Watchdogger') { 'System Initialized' }
      @watch_interval = options.get_value(:interval, 60).to_i
      @pidfile = options.get_value(:pidfile) || File.join(Etc.getpwuid.dir, '.watchdogger.pid')
      @pidfile = File.expand_path(@pidfile)
    end
    
    
    # This is the main loop of the watcher
    def watch_loop
      signal_traps
      dog_log.info('Watchdogger') { "Starting watch loop with interval #{@watch_interval}"}
      loop do
        Watcher.watch_all!
        sleep(@watch_interval)
      end
    end
    
    # Run as a daemon
    def daemon 
      raise(RuntimeError, "Daemon still running") if(check_daemon)
      raise(ArgumentError, "Not daemonizing without a logfile") unless(@logfile && @logfile.upcase != 'STDOUT' && @logfile.upcase != 'STDERR') 
      # Test the file opening before going daemon, so we know that
      # it should usually work
      File.open(@pidfile, 'w') { |io| io << 'starting' }
      daemonize
      # Now write the pid for real
      File.open(@pidfile, 'w') { |io| io << Process.pid.to_s }
      dog_log.info('Watchdogger') { "Running as daemon with pid #{Process.pid}" }
      watch_loop
    end
    
    # By default, camelize converts strings to UpperCamelCase. If the argument to camelize
    # is set to ":lower" then camelize produces lowerCamelCase.
    #
    # camelize will also convert '/' to '::' which is useful for converting paths to namespaces
    #
    # Examples
    #   "active_record".camelize #=> "ActiveRecord"
    #   "active_record".camelize(:lower) #=> "activeRecord"
    #   "active_record/errors".camelize #=> "ActiveRecord::Errors"
    #   "active_record/errors".camelize(:lower) #=> "activeRecord::Errors"
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true) # :nodoc:
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
    
    # Shutdown the given daemon
    def shutdown_daemon
      Process.kill('TERM', get_pid)
    end
    
    # Check for running daemon. Returns true if the system thinks that the 
    # daemon is still running.
    def check_daemon
      return false unless(File.exists?(@pidfile))
      pid = get_pid
      begin
        Process.kill(0, pid)
        true
      rescue Errno::EPERM
        true
      rescue Errno::ESRCH
        dog_log.info('Watchdogger') { "Old process #{pid} is stale, good to go." }
        false
      rescue Exception => e
        dog_log.error('Watchdogger') { "Could not find out if process #{pid} still runs (#{e.message}). Hoping for the best..." }
        false
      end
    end
    
    private
    
    def get_pid
      pid = File.open(@pidfile, 'r') { |io| io.read }
      pid.to_i
    end
    
    # Clean shutdown
    def shutdown
      dog_log.info('Watchdogger') { "Cleaning watchers..." }
      Watcher.cleanup_watchers
      if(@my_pidfile)
        dog_log.info('Watchdogger') { "Removing pidfile at #{@my_pidfile}" }
        FileUtils.remove(@my_pidfile) if(File.exists?(@my_pidfile))
      end
      dog_log.info('Watchdogger') { "Shutting down."}
      exit(0)
    end
    
    # Setup handler for the signals that should be handled by the skript
    def signal_traps
      Signal.trap('INT') { shutdown }
      Signal.trap('TERM') { shutdown }
      Signal.trap('HUP', 'IGNORE')
    end
    
    # File active_support/core_ext/kernel/daemonizing.rb, line 4
    def daemonize
      exit if fork                   # Parent exits, child continues.
      Process.setsid                 # Become session leader.
      exit if fork                   # Zap session leader. See [1].
      Dir.chdir "/"                  # Release old working directory.
      File.umask 0000                # Ensure sensible umask. Adjust as needed.
      STDIN.reopen "/dev/null"       # Free file descriptors and
      STDOUT.reopen "/dev/null", "a" # point them somewhere sensible.
      STDERR.reopen STDOUT           # STDOUT/ERR should better go to a logfile.
    end
    
  end
  
end

class Hash # :nodoc:
  
  # Gets the value from the Hash, regardless if it's stored with a symbol
  # or a key as a string. You may supply a default value - if the default
  # is set to false, the method will raise an argument error. By default, it
  # will return nil if the element isn't found.
  def get_value(sym_or_string, default = nil)
    value = self[sym_or_string.to_s] || self[sym_or_string.to_sym] || default
    raise(ArgumentError, "No value set for #{sym_or_string}") if((default == false) && !value)
    value
  end
  
  # Gets the given key as an array. If it's already an array, it will be returned,
  # otherwise we'll check if it's a comma-separated list. The
  # default will be processed in the same way as if was read from the Hash.
  def get_list(sym_or_string, default = nil)
    value = get_value(sym_or_string, default)
    return value if(value.is_a?(Array))
    assit(value.is_a?(String) || value.is_a?(Symbol))
    value = value.to_s.split(',').collect do |val|
      val.strip 
    end
  end
  
end