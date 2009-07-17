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
      actions = config.get_list(:actions, false)
      actions.each { |ac| add_action(ac) }
    end
    
    def execute(event)
      @actions.each { |ac| WatcherAction.run_action(ac, event) }
    end
    
    def add_action(action)
      @actions ||= []
      raise(ArgumentError, "Trying to add myself, creating a loop.") if(WatcherAction.is_action?(action, self))
      @actions << action
    end
    
  end
  
end