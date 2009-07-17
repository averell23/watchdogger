require File.join(File.dirname(__FILE__), 'test_helper')

class MetaActionTest < Test::Unit::TestCase
  
  def setup
    clear_registered
    WatcherAction.register('child1', { :type => 'dummy_action' })
    WatcherAction.register('child2', { :type => 'dummy_action' })
    @meta = WatcherAction::MetaAction.new(:actions => ['child1', 'child2'])
  end
  
  def test_simple
    assert_equal(nil, action_status('child1'))
    assert_equal(nil, action_status('child2'))
    @meta.execute(WatcherEvent.new)
    assert_equal(true, action_status('child1'))
    assert_equal(true, action_status('child2'))
  end
  
end