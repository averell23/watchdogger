require 'rmail'
require 'tlsmail' if(/^1.8/ =~ RUBY_VERSION) # Include the hack for ruby 1.8
require 'net/smtp'
require 'time'

module WatcherAction
  
  # This action will send an email to a given receipient. It doesn't support any
  # fancy features (you may want to do that handling externally).
  # 
  # =Options
  #
  # [*to*] Email address to which to send the message. May be a list. (required)
  # [*sender*] Email address of the person sending the mail (required)
  # [*subject*] Subject of the message. You can put %s for the event message. (defaults if not set)
  # [*body*] Body of the email message. If set to 'xml', it will include an
  #          XML representation of the event. If not set, it will default
  #          to a sensible description of the event. You can include the
  #          event's message as for the subject
  # [*server*] Address or name of the mail server to use (defaults to localhost)
  # [*port*] Port to connect to (default: 25)
  # [*user*] Mail server user name
  # [*pass*] Mail server password
  # [*authentication*] Authentication method (default: plain)
  # [*enable_tls*] Use the TLS encryption (default: false)
  class SendMail
    
    def initialize(config)
      @mail_to = config.get_value(:to, false)
      @sender = config.get_value(:sender, false)
      @subject = config.get_value(:subject, "Watchdogger needs your attention.")
      @body = config.get_value(:body)
      @server = config.get_value(:server, 'localhost')
      @port = config.get_value(:port, '25')
      @user = config.get_value(:user)
      @pass = config.get_value(:pass)
      @authentication = config.get_value(:authentication, :plain).to_sym
      @enable_tls = config.get_value(:enable_tls) || false
    end
    
    def execute(event)
      msg = RMail::Message.new
      msg.header.to = @mail_to
      receipient = msg.header.to.to_s.split(',').first
      msg.header.from = @sender
      msg.header.subject =  @subject % [event.message]
      msg.header.date = Time.now
      if(@body.to_s == 'xml')
        msg.body = event.to_xml
      elsif(@body)
        msg.body = @body % [event.message]
      else
        msg.body = "The #{event.watcher.class.name} watcher of your watchdog triggered\nan event at #{event.timestamp}:\n#{event.message}"
      end
      
      
      puts msg.to_s
      
      smtp_params = [@server, @port]
      if(@user && @pass)
        smtp_params.concat([nil, @user, @pass, @authentication])
      end
      
      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE) if(@enable_tls)
      Net::SMTP.start(*smtp_params) do |smtp|
        smtp.send_message(msg.to_s, @sender, @mail_to)
      end
      dog_log.debug('SMTP Action') { "Sent mail to #{@mail_to} through #{@server}" }
    rescue Exception => e
      dog_log.warn('SMTP Action') { "Could not send mail to #{@mail_to} on #{@server}: #{e.message}" }
    end
    
  end

end