# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'
require 'socket'

begin
  require 'hrr_rb_ssh'
rescue LoadError
  $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'hrr_rb_ssh'
end


logger = Logger.new STDOUT
logger.level = Logger::INFO
HrrRbSsh::Logger.initialize logger


auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
  true # accept any user and password
}

conn_echo = HrrRbSsh::Connection::RequestHandler.new { |context|
  context.chain_proc { |chain|
    case context.subsystem_name
    when 'echo'
      begin
        loop do
          begin
            buf = context.io[0].readpartial(10240)
          rescue EOFError
            break
          end
          context.io[1].write buf
        end
        exitstatus = 0
      rescue => e
        logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
        exitstatus = 1
      end
    else
      exitstatus = 0
    end
    exitstatus
  }
}

options = {}
options['authentication_password_authenticator'] = auth_password
options['connection_channel_request_subsystem']  = conn_echo


server = TCPServer.new 10022
while true
  t = Thread.new(server.accept) do |io|
    begin
      tran = HrrRbSsh::Transport.new      io, HrrRbSsh::Mode::SERVER
      auth = HrrRbSsh::Authentication.new tran, options
      conn = HrrRbSsh::Connection.new     auth, options
      conn.start
    rescue => e
      logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
    ensure
      io.close
    end
  end
end
