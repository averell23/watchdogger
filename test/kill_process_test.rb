require File.join(File.dirname(__FILE__), 'test_helper')

PIDFILE = 'test.pid'

class KillProcessTest < Test::Unit::TestCase
  
  def setup
    @killer = WatcherAction::KillProcess.new(:pidfile => PIDFILE, :restart_time => '3')
    # Fork a dummy process that we can kill
    fork_process
  end
  
  def teardown
    FileUtils.remove(PIDFILE) if(File.exists?(PIDFILE))
    @proc.terminate! if(@proc.status != false)
  rescue Exception => e
    puts "! unclean teardown #{e}"
  end
  
  def test_killer
    assert_not_equal(false, @proc.status)
    @killer.execute(WatcherEvent.new)
    sleep 1 # Wait for the sleep - the ruby process will handle the kill only then
    assert_equal(false, @proc.status)
  end
  
  def test_restart_killer
    assert_not_equal(false, @proc.status)
    @killer.execute(WatcherEvent.new)
    sleep 1 # Wait for the sleep - the ruby process will handle the kill only then
    assert_equal(false, @proc.status)
    fork_process
    # Within the restart time, this should be ignored
    @killer.execute(WatcherEvent.new)
    sleep 1
    assert_not_equal(false, @proc.status)
    sleep 2
    # Now it should work again
    @killer.execute(WatcherEvent.new)
    sleep 1
    assert_equal(false, @proc.status)
  end
  
  private
  
  def fork_process
    assert(!@proc || @proc.status == false, "Cannot refork with old proc running")
    @pid = Process.fork { loop { sleep 1 }}
    @proc = Process.detach(@pid)
    File.open(PIDFILE, 'w') { |io| io << @pid }
  end
  
end