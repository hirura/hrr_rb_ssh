# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'

begin
  require 'hrr_rb_ssh'
rescue LoadError
  $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  require 'hrr_rb_ssh'
end

logger = Logger.new STDOUT
logger.level = Logger::INFO
logger.level = Logger::DEBUG
HrrRbSsh::Logger.initialize logger

address = 'localhost'
options = {
  port: 10022,
  username: 'user1',
  password: 'password1',
  publickey: ['ssh-rsa', "/home/user1/.ssh/id_rsa"],
  keyboard_interactive: [
    'password1',
    #'password2' # when keyboard-interactive authentication requires 2nd response
  ],
}
HrrRbSsh::Client.start(address, options){ |conn|
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
}
