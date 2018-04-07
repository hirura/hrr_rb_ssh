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
logger.level = Logger::INFO
HrrRbSsh::Logger.initialize logger


auth_none = HrrRbSsh::Authentication::Authenticator.new { |context|
  false
}
auth_publickey = HrrRbSsh::Authentication::Authenticator.new { |context|
  username = 'user1'
  dss_public_key_algorithm_name = 'ssh-dss'
  dss_public_key = <<-'EOB'
-----BEGIN PUBLIC KEY-----
  MIIBtzCCASwGByqGSM44BAEwggEfAoGBAKh2ZJp4ao8Xaexa0sk68VqMCaOaTi19
YIqo2+t2t8ve4QSHvk/NbFIDTGq90lHziakTqwKaaswWLB7cSRPTcXjLv16Zmazg
JRvh1jZ3ikuBME2G/B+EptlQ00dMa+5W/Acp2P6Cv5NRgA/tx0AyCJaItSpLXG+k
B+HMp9LQ8WotAhUAk/yyvpsY9sVSyeN3lHvg5Nsl568CgYEAj4rqF241ROP2olNh
VJUF0K5N4dSBCfcPnSPYuGPCi7qV229RISET3LOwrCXEUwSwlKoe/lLb2mcaeC84
NIeN6pQnRTE6zajJ9UUeGErOFRm1x6E+FMtlVp/fwUE1Ra+AscHVKwMUehz7sA6A
ZxJK7UvLs+R6s1eYhrES0bcorLIDgYQAAoGAd6XKzevlwzt6aCYdBRdN+BT4BQUw
/L3MVYG0kDV9WqPcyAFvLO54xAUf9LxYM0e8X8J5ECp4oEGOcK1ilXEw3LPMJGmY
IB56R9izS1t636kxnJTYNGQY+XvjAeuP7nC2WVNHNz7vXprT4Sq+hQaNkaKPu/3/
48xJs2mYbxfyHCQ=
-----END PUBLIC KEY-----
  EOB
  rsa_public_key_algorithm_name = 'ssh-rsa'
  rsa_public_key = <<-'EOB'
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3OnIQcRTdeTZFjhGcx8f
ssCgeqzY47p5KhT/gKMz2nOANNLCBr9e6IGaRePew03St3Cn0ApikuGzPnWxSlBT
H6OpR/EnUmBttlvcL28CGOsZIwYJtAdVsGXpIXtiPLl2eEzaM9aBsS/LGWKgQNo3
86UGa5j20yGJfsL9WIMCVoGvsA06+4VX1/zlWXwVJSNep674bmSWPcVtXWWZIk19
T6b+xuqhfiUpbc/stfdmgDc3B/ZgpFsQh5oWBoAfkL6kAEa4oQBFhqF0QM5ej6h5
wqbQt4paM0aEuypWE+CaizA0I+El7f0y+59sUqTAN/7F9UlXaOBdd9SZkhACBrAR
nQIDAQAB
-----END PUBLIC KEY-----
  EOB
  [
    [dss_public_key_algorithm_name, dss_public_key],
    [rsa_public_key_algorithm_name, rsa_public_key],
  ].any? { |public_key_algorithm_name, public_key|
    context.verify username, public_key_algorithm_name, public_key
  }
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
conn_exec = HrrRbSsh::Connection::RequestHandler.new { |context|
  context.chain_proc { |chain|
    pid = fork do
      Process.setsid
      context.vars[:env] ||= Hash.new
      exec context.vars[:env], context.command, in: context.io, out: context.io, err: context.io
    end
    pid, status = Process.waitpid2 pid
    status.exitstatus
  }
}


options = {}

options['authentication_none_authenticator']      = auth_none
options['authentication_publickey_authenticator'] = auth_publickey
options['authentication_password_authenticator']  = auth_password

options['connection_channel_request_pty_req'] = conn_pty
options['connection_channel_request_env']     = conn_env
options['connection_channel_request_shell']   = conn_shell
options['connection_channel_request_exec']    = conn_exec


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
