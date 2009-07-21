module WatcherAction
  
  # Kills the process with the given PID.
  #
  # =Options
  #
  # [*pidfile*] The file containing the process id
  # [*signal*] The signal to send to the process. 
  #            This may be an array or a comma-separated
  #            list of signals. If there is more than one signal, this
  #            will wait for _wait_ seconds before trying the next
  #            signal, if the process didn't die.
  #            Defaults to KILL
  # [*wait*] Time to wait between signals (Default: 5)
  # [*restart_time*] Time allowed for the process to restart. The action
  #                  will not do anything if called again during this
  #                  interval. (Default: 120)
  class KillProcess
    
    def initialize(config)
      @pidfile = config.get_value(:pidfile, false)
      @signals = config.get_list(:signal, 'KILL')
      @wait = config.get_value(:wait, 5).to_i
      @restart_time = config.get_value(:restart_time, 120).to_i
    end
    
    def execute(event)
      if(@last_action && (Time.now - @last_action).floor < @restart_time)
        dog_log.info("Ignoring restart request in restarting time.")
        return false
      end
      
      Thread.new(@signals, @wait, @pidfile) do |signals, wait, pidfile|
        pid = File.open(pidfile) { |io| io.read }.to_i
        signals.each_with_index do |signal, index|
          sleep(wait) if(index > 0)
          if(WatchDogger.check_process(pid))
            dog_log.debug('KillerThread') { "Sending signal #{signal} to process #{pid}" }
            Process.kill(signal, pid)
          else
            dog_log.debug('KillerThread') { "Process #{pid} is dead." }
          end
        end
      end
      @last_action = Time.now
    rescue Exception => e
      dog_log.warn { "Unable to kill process: #{e}" }
    end
    
  end
  
end