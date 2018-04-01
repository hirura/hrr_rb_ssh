# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'
require 'pty'
require 'socket'

begin
  require 'hrr_rb_ssh'
rescue LoadError
  $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'hrr_rb_ssh'
end


logger = Logger.new STDOUT
logger.level = :info
HrrRbSsh::Logger.initialize logger


options = {}

auth_none = HrrRbSsh::Authentication::Authenticator.new { |context|
  false
}
auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
  user_and_pass = [
    ['user1',  'password1'],
    ['user2',  'password2'],
  ]
  user_and_pass.any? { |user, pass|
    context.verify user, pass
  }
}

conn_pty = HrrRbSsh::Connection::RequestHandler.new { |context|
  ptm, pts = PTY.open
  context.vars[:ptm] = ptm
  context.vars[:pts] = pts
  context.chain_proc { |chain|
    begin
      chain.call_next
    ensure
      context.vars[:ptm].close
      context.vars[:pts].close
    end
  }
}
conn_env = HrrRbSsh::Connection::RequestHandler.new { |context|
  context.vars[:env] ||= Hash.new
  context.vars[:env][context.variable_name] = context.variable_value
}
conn_shell = HrrRbSsh::Connection::RequestHandler.new { |context|
  ptm = context.vars[:ptm]
  pts = context.vars[:pts]

  context.chain_proc { |chain|
    pid = fork do
      ptm.close
      Process.setsid
      STDIN.reopen  pts, 'r'
      STDOUT.reopen pts, 'w'
      STDERR.reopen pts, 'w'
      pts.close
      context.vars[:env] ||= Hash.new
      exec context.vars[:env], 'login', '-f', context.username
    end

    pts.close

    threads = []
    threads.push Thread.start {
      loop do
        begin
          context.io.write ptm.readpartial(1024)
        rescue EOFError => e
          context.logger.info("ptm is EOF")
          break
        rescue IOError => e
          context.logger.warn("IO is closed")
          break
        rescue => e
          context.logger.error(e.full_message)
          break
        end
      end
    }
    threads.push Thread.start {
      loop do
        begin
          ptm.write context.io.readpartial(1024)
        rescue EOFError => e
          context.logger.info("IO is EOF")
          break
        rescue IOError => e
          context.logger.warn("IO is closed")
          break
        rescue => e
          context.logger.error(e.full_message)
          break
        end
      end
    }

    pid, status = Process.waitpid2 pid
    threads.each do |t|
      begin
        t.exit
        t.join
      rescue => e
        context.logger.error(e.full_message)
      end
    end
    status.exitstatus
  }
}

options['authentication_none_authenticator']     = auth_none
options['authentication_password_authenticator'] = auth_password
options['connection_channel_request_pty_req']    = conn_pty
options['connection_channel_request_env']        = conn_env
options['connection_channel_request_shell']      = conn_shell


server = TCPServer.new 10022
while true
  t = Thread.new(server.accept) do |io|
    tran = HrrRbSsh::Transport.new      io, HrrRbSsh::Transport::Mode::SERVER
    auth = HrrRbSsh::Authentication.new tran, options
    conn = HrrRbSsh::Connection.new     auth, options
    conn.start
    io.close
  end
end
