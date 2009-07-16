require 'logger'

# Logging facility for the watchdog
class DogLog # :nodoc:
  
  class << self
    
    # Set the log file and severity. This will reset the current logger,
    # but should not usually be called on an active log.
    def setup(logfile, severity)
      @logfile = logfile
      @severity = Logger.const_get(severity.upcase)
      if(@logger)
        assit_fail('Resetting logfile')
        @logger.close if(@logger.respond_to?(:close))
        @logger = nil
      end
    end
    
    # If nothing is configured, we log to STDERR by default
    def logger
      @logger ||= begin
        @logfile ||= STDERR
        severity = @severity || Logger::DEBUG
        logger = Logger.new(get_log_io, 3)
        logger.level = severity
        logger
      end
    end
    
    def get_log_io
      return @logfile if(@logfile.kind_of?(IO))
      if(Module.constants.member?(@logfile.upcase))
        const = Module.const_get(@logfile.upcase)
        return const if(const.kind_of?(IO))
      end
      File.open(@logfile, 'a')
    end
    
    
  end
end

class Object # :nodoc:
  def self.dog_log
    DogLog.logger
  end
  
  def dog_log
    DogLog.logger
  end
end