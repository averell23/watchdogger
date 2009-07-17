module Watcher
  
  # Base class for all Watcher.
  #
  # A watcher checks for a condition (e.g., if a web site responds, if a log file shows signs of
  # trouble). Each watcher will have one or more actions attached that will be called if the
  # watched condition is triggered.
  #
  # =Options
  #
  # Each watcher will accept the following options, which are handled by the superclass:
  #
  # [*severity*] Severity of the event. Each time the event is triggered, the watcher will
  #              add this value to the internal "severity". If the internal severity reaches
  #              100, the action is triggered. This means that with a severity of 100 the
  #              action is run each time the watcher triggers. With a severity of 1, it is
  #              only executed every 100th time. The global mechanism will reset the
  #              severity once the action is triggered. The watcher class may decide
  #              to reset the severity also on other occasions. Default: 100
  #   
  # [*actions*] The actions that should be executed when the watcher triggers. These 
  #             are names of actions that have been set up previously. (Required)
  #  
  # [*warn_actions*] Additional actions that are executed if the watcher triggers, but the 
  #                  severity for a real action is not yet reached.
  #
  # Each watcher object must respond to the #watch_it! method. It must check the watched condition
  # and return nil or false if the condition is not met. If the condition is met, it may return
  # true or an error message.
  #
  # The Watcher _may_ also respond to the #cleanup method - which will be used to clean
  # up all existing Watcher on a clean shutdown.
  class Base
    attr_accessor :severity
    attr_accessor :name

     # Sets up all actions for this watcher
     def setup_actions(configuration)
       action_config = configuration.get_value(:actions)
       raise(ArgumentError, "No actions passed to watcher.") unless(action_config)
       if(action_config.is_a?(Array))
         action_config.each { |ac| actions << ac }
       else
         assit(action_config.is_a?(String) || action_config.is_a?(Symbol))
         actions << action_config
       end
       warn_config = configuration.get_value(:warn_actions)
       if(warn_config.is_a?(Array))
         warn_config.each { |ac| warn_actions << ac }
       elsif(warn_config)
         assit_kind_of(String, warn_config)
         warn_actions << warn_config
       end
     end

     private

     # Checks the trigger and does everything to call the actions connected to this watcher
     def do_watch!
       @current_severity ||= 0
       result = watch_it!
       return unless(result)

       event = WatcherEvent.new
       event.watcher = self
       event.message = result unless(result.is_a?(TrueClass))
       event.timestamp = Time.now

       @current_severity = @current_severity + severity
       if(@current_severity >= 100)
         run_actions(event)
         @current_severity = 0
       else
         run_warn_actions(event)
       end

       @last_run = Time.now
     end

     # Executes all actions for this watcher
     def run_actions(event)
       actions.each { |ac| WatcherAction.run_action(ac, event) }
     end

     def run_warn_actions(event)
       warn_actions.each { |ac| WatcherAction.run_action(ac, event) }
     end

     def actions
       @actions ||= []
     end

     def warn_actions
       @warn_actions ||= []
     end
  end
  
end