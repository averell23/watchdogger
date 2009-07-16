# Handling for the Watcher objects in the system. The Watcher are not access directly,
# but handled through the static methods of this module. The module will also keep track
# of the watcher state and wrap the invocation procedure.
module Watcher
  
  # Number of times the Watcher were called
  @@watch_runs = 0
  
  class << self
    
    # Create a new watcher with the given configuration. The type identifies the watcher class
    # that should be used.
    # 
    # This will *not* return the watcher object, as it is not to be used externally. The watcher
    # will be registered internally, and called when the #watch_all! method is called
    def register(name, config_options)
      assit_kind_of(String, name)
      raise(ArgumentError, "Illegal options") unless(config_options.is_a?(Hash))
      type = config_options.get_value(:type, false)
      type = WatchDogger.camelize(type)
      watcher =  Watcher.const_get(type).new(config_options)
      watcher.setup_actions(config_options)
      severity = config_options.get_value(:severity, 100).to_i
      watcher.severity = severity
      watcher.name = name
      registered_watchers << watcher
      dog_log.debug('Watcher') { "Registered Watcher of type #{type}" }
    end
  
    # This will execute all registered Watcher, which, in turn, will execute their
    # actions if necessary. Normally, this will run all Watcher each time this method is
    # called. However, the watcher may implement conditions on which the check is skipped.
    def watch_all!
      @last_check = Time.now
      registered_watchers.each { |w| w.send(:do_watch!) }
    end
    
    # Cleans up all Watcher
    def cleanup_watchers
      registered_watchers.each { |w| w.cleanup if(w.respond_to?(:cleanup)) }
    end
    
    private
  
    def registered_watchers
      @registered_watchers ||= []
    end
    
  end # end class methods
  
end