require File.join(File.dirname(__FILE__), 'test_helper')

# The URL that will be used for testing. Should return a 200 result and a body.
TEST_URL = 'http://wiki.github.com/averell23/watchdogger'
# Text that will be expected in the page body
TEST_URL_TEXT = 'averell23'

class HttpWatcherTest < Test::Unit::TestCase

  def setup
    @default_options = {
      :url => TEST_URL, 
      :actions => 'default', 
      :timeout => '2'
    }
  end
  
  def test_simple
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_equal(false, watcher.watch_it!)
  end

  def test_simple_match
    @default_options[:content_match] = TEST_URL_TEXT
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_equal(false, watcher.watch_it!)
  end

  def test_simple_response
    @default_options[:response] = '200'
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_equal(false, watcher.watch_it!)
  end

  def test_simple_response_numerical
    @default_options[:response] = 200
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_equal(false, watcher.watch_it!)
  end

  def test_404_response
    @default_options[:url] = TEST_URL + '/narfnarf'
    @default_options[:response] = '404'
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_equal(false, watcher.watch_it!)
  end
  
  def test_404_response_fail
    @default_options[:url] = TEST_URL + '/narfnarf'
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_kind_of(String, watcher.watch_it!)
  end
  
  def test_simple_match_fail
    @default_options[:content_match] = 'grubellnurf'
    watcher = Watcher::HttpWatcher.new(@default_options)
    assert_kind_of(String, watcher.watch_it!)
  end
  
  def test_illegal_open_fail
    watcher = Watcher::HttpWatcher.new(
    :url => 'http://www.gurgl.gurl/', 
    :actions => 'default',
    :content_match => 'grubellnurf'
    )
    assert_kind_of(String, watcher.watch_it!)
  end

end