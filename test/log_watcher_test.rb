require File.join(File.dirname(__FILE__), 'test_helper')

class LogWatcherTest < Test::Unit::TestCase
  
  def logfile
    File.expand_path(File.join(File.dirname(__FILE__), 'log_test.tmp'))
  end
  
  def setup
    FileUtils.remove(logfile) if(File.exists?(logfile))
    File.open(logfile, 'w') { |io| io << 'test' }
    @watcher = Watcher::LogWatcher.new(
      :logfile => logfile,
      :match => 'da_test',
      :interval_first => '1',
      :interval_max => '1'
    )
  end
  
  def teardown
    @watcher.cleanup
    FileUtils.remove(logfile) if(File.exists?(logfile))
  end
  
  def test_watcher_plain
    assert_equal(false, @watcher.watch_it!)
  end
  
  def test_watcher_trigger
    File.open(logfile, 'a') do |io|
      20.times { io << 'nothing special' }
      io << 'da_test'
    end
    sleep 2
    assert_kind_of(String, @watcher.watch_it!)
  end
  
end