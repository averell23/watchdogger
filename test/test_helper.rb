require 'rubygems'
require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib', 'watchdogger')

DogLog.setup('tmp.log', Logger::DEBUG)

module Watcher
  class DummyWatcher < Watcher::Base
    def initialize(config)
      @watchit = config[:watchit]
    end
    def watch_it!
      @watchit
    end
    
  end
end

module WatcherAction
  class DummyAction
    def initialize(config)
    end
    def execute(event)
      @executed = true
      raise(Exception) unless(event.is_a?(WatcherEvent))
      raise(ArgumentError, "Boom!")
    end
  end
end

# Add some methods to the test case class
class Test::Unit::TestCase # :nodoc:
  private
  
  def action_status(name)
    action = WatcherAction.instance_variable_get(:@registered_actions).get_value(name)
    action.instance_variable_get(:@executed)
  end
  
  def clear_registered
    Watcher.instance_variable_set(:@registered_watchers, nil)
    WatcherAction.instance_variable_set(:@registered_actions, nil)
  end
  
end