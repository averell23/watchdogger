require File.join(File.dirname(__FILE__), 'test_helper')

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

class WatchdoggerTest < Test::Unit::TestCase
  
  def setup
    Watcher.instance_variable_set(:@registered_watchers, nil)
    WatcherAction.instance_variable_set(:@registered_actions, nil)
    WatcherAction.register('default', { :type => 'dummy_action' })
    WatcherAction.register('log_action', { 'type' => :log_action })
    Watcher.register('dummy', { :type => 'dummy_watcher', 'actions' => [ :default, :log_action ] })
  end
  
  def test_create_watcher
    watchers = Watcher.instance_variable_get(:@registered_watchers)
    assert_equal(1, watchers.size)
    assert_kind_of(Watcher::DummyWatcher, watchers.first)
  end
  
  def test_watcher_actions
    actions = Watcher.instance_variable_get(:@registered_watchers).first.send(:actions)
    assert_equal([:default, :log_action], actions)
  end
  
  def test_registered_action
    actions = WatcherAction.instance_variable_get(:@registered_actions)
    assert_equal(2, actions.size)
    assert_kind_of(WatcherAction::DummyAction, actions[:default])
    assert_kind_of(WatcherAction::LogAction, actions[:log_action])
  end
  
  def test_run_action
    event = WatcherEvent.new
    event.timestamp = Time.now
    event.message = "TEST MESSAGE"
    event.watcher = "TEST"
    assert_equal(false, WatcherAction.run_action('default', event))
    assert_equal(true, action_status('default'))
    WatcherAction.run_action('log_action', event)
  end
  
  def test_run_watcher
    assert_nothing_raised { Watcher.watch_all! }
  end
  
  def test_run_watcher_execute
    assert_equal(nil, action_status('default'))
    Watcher.register('dummy2', { 'type' => :dummy_watcher, 'actions' => :default, :watchit => 'Fail' })
    Watcher.watch_all!
    assert_equal(true, action_status('default'))
  end
  
  def test_warn_actions
    WatcherAction.register('default-warn', { :type => 'dummy_action' })
    assert_equal(nil, action_status('default'))
    assert_equal(nil, action_status('default-warn'))
    Watcher.register('dummy2', { 'type' => :dummy_watcher, 'actions' => :default, 'warn_actions' => 'default-warn', :watchit => 'Fail' , :severity => '50' })
    Watcher.watch_all!
    assert_equal(true, action_status('default-warn'))
    assert_equal(nil, action_status('default'))
    Watcher.watch_all!
    assert_equal(true, action_status('default'))
  end
  
  private
  
  def action_status(name)
    action = WatcherAction.instance_variable_get(:@registered_actions).get_value(name)
    action.instance_variable_get(:@executed)
  end
end