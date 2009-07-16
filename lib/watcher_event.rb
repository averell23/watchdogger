require 'builder'

# Encodes the information of an event that was triggered.
class WatcherEvent
  
  attr_accessor :timestamp
  attr_accessor :watcher
  attr_accessor :message
  
  def to_xml
    builder = Builder::XmlMarkup.new()
    builder.instruct!
    builder.event do 
      builder.timestamp(timestamp)
      builder.message(message)
      builder.watcher do
        builder.name(watcher.name)
        builder.watcher_type(watcher.class.name)
      end
    end
  end
    
end