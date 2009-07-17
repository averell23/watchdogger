module WatcherAction
  
  # An action to call other actions. This can be used to "aggregate" combinations of
  # actions that should always go together, so that the same combinations do
  # not have to repeated multiple times
  #
  # = Options
  # 
  # [*actions*] A list of the actions that should be executed. (required)
  class MetaAction
    
    def initialize(config)
      actions = config.get_value(:actions, false)
      if(actions.is_a?(Array))
        @actions = actions
      else
        @actions = [ actions ]
      end
    end
    
    def execute(event)
      @actions.each { |ac| WatcherAction.run_action(ac, event) }
    end
    
  end
  
end