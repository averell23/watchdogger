# Each action object contains the action that will be taken when a watched condition is triggered.
#
# Each action must respond to the #execute(event) method, which will execute the action.
#
# Actions should *not* log the executing to the log file, unless there is an unexpected error
# in the execution of the action itself. If the user wants to log to the log file,
# the logger action should be used. (All actions may use the log for debug-level information
# in all places.)
module WatcherAction
  
  class << self
  
    # creates a new action of the given type. The Action object itself will not
    # be made public, instead call the #run_action method to execute it
    def register(name, config_options)
      assit_kind_of(String, name)
      raise(ArgumentError, "Illegal options.") unless(config_options.is_a?(Hash))
      type = config_options.get_value(:type, false)
      type = WatchDogger.camelize(type)
      registered_actions[name.to_sym] = WatcherAction.const_get(type).new(config_options)
      dog_log.debug('Action Handler') { "Registered action '#{name}' of type #{type}"}
    end
    
    # Runs the named action. Returns true if the action ran without exception.
    def run_action(name, event)
      registered_actions[name.to_sym].execute(event)
      true
    rescue Exception => e
      dog_log.error('Action Handler') { "Could not execute #{name}: #{e.message} (Registered actions: #{registered_actions.keys.join(', ')})" }
      false
    end
    
    # Checks if the given action exists
    def has_action?(name)
      registered_actions[name.to_sym] != nil
    end
  
    private
    
    def registered_actions
      @registered_actions ||= {}
    end
  
  end
  
end