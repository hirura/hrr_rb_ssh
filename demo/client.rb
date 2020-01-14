# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'

begin
  require 'hrr_rb_ssh'
rescue LoadError
  $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'hrr_rb_ssh'
end

class MyLoggerFormatter < ::Logger::Formatter
  def call severity, time, progname, msg
    "%s, [%s#%d.%x] %5s -- %s: %s\n" % [severity[0..0], format_datetime(time), Process.pid, Thread.current.object_id, severity, progname, msg2str(msg)]
  end
end

logger = Logger.new STDOUT
logger.level = Logger::DEBUG
logger.formatter = MyLoggerFormatter.new

target = ['localhost', 10022]
options = {
  username: 'user1',
  password: 'password1',
  publickey: ['ssh-rsa', "/home/user1/.ssh/id_rsa"],
  keyboard_interactive: [
    'password1',
    #'password2' # when keyboard-interactive authentication requires 2nd response
  ],
}
HrrRbSsh::Client.start(target, options, logger: logger){ |conn|
  puts conn.exec!('ls -l') # => [out, err]

  puts conn.exec!('ls -l', pty: true) # => [out, err] # "ls -l" command will be run on PTY

  conn.exec('ls -l', pty: true){ |io_in, io_out, io_err| # => exit status
    while true
      begin
        print io_out.readpartial(10240)
      rescue EOFError
        break
      end
    end
  }

  conn.shell{ |io_in, io_out, io_err| # => exit status
    t = Thread.new {
      while true
        begin
          print io_out.readpartial(10240)
        rescue EOFError
          break
        end
      end
    }
    io_in.puts "ls -l"
    io_in.puts "exit"
    t.join
  }

  conn.subsystem("echo"){ |io_in, io_out, io_err| # => exit status
    t = Thread.new {
      print io_out.readpartial(10240) rescue nil
    }
    io_in.puts "string"
    t.join
    io_in.close
  }
}
