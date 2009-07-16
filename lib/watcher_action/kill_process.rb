module WatcherAction
  
  # Kills the process with the given PID.
  # Options: 
  #
  #  pidfile    - The file containing the process id
  #  signal     - The signal to send to the process. Defaults to KILL
  class KillProcess
    
    def initialize(config)
      @pidfile = config.get_value(:pidfile, false)
      @signal= config.get_value(:signal, 'KILL')
    end
    
    def execute(event)
      pid = File.open(@pidfile) { |io| io.read }
      Process.kill(@signal, pid.to_i)
    rescue Exception => e
      dog_log.warn { "Unable to kill process: #{e}" }
    end
    
  end
  
end