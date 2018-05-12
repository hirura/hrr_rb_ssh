# coding: utf-8
# vim: et ts=2 sw=2

require 'etc'
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


tran_preferred_encryption_algorithms      = %w(aes128-ctr aes192-ctr aes256-ctr aes128-cbc 3des-cbc blowfish-cbc cast128-cbc aes192-cbc aes256-cbc arcfour)
tran_preferred_server_host_key_algorithms = %w(ecdsa-sha2-nistp521 ecdsa-sha2-nistp384 ecdsa-sha2-nistp256 ssh-rsa ssh-dss)
tran_preferred_kex_algorithms             = %w(ecdh-sha2-nistp521 ecdh-sha2-nistp384 ecdh-sha2-nistp256 diffie-hellman-group14-sha1 diffie-hellman-group1-sha1)
tran_preferred_mac_algorithms             = %w(hmac-sha2-512 hmac-sha2-256 hmac-sha1 hmac-md5 hmac-sha1-96 hmac-md5-96)
tran_preferred_compression_algorithms     = %w(none zlib)

auth_none = HrrRbSsh::Authentication::Authenticator.new { |context|
  false
}
auth_publickey = HrrRbSsh::Authentication::Authenticator.new { |context|
  users = ['user1', 'user2']
  users.any?{ |username|
    passwd = Etc.getpwnam(username)
    homedir = passwd.dir
    authorized_keys = HrrRbSsh::Compat::OpenSSH::AuthorizedKeys.new(File.read(File.join(homedir, '.ssh', 'authorized_keys')))
    authorized_keys.any?{ |public_key|
      context.verify username, public_key.algorithm_name, public_key.to_pem
    }
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


options = {}

options['transport_preferred_encryption_algorithms']      = tran_preferred_encryption_algorithms
options['transport_preferred_server_host_key_algorithms'] = tran_preferred_server_host_key_algorithms
options['transport_preferred_kex_algorithms']             = tran_preferred_kex_algorithms
options['transport_preferred_mac_algorithms']             = tran_preferred_mac_algorithms
options['transport_preferred_compression_algorithms']     = tran_preferred_compression_algorithms

options['transport_server_secret_host_keys'] = {}
options['transport_server_secret_host_keys']['ecdsa-sha2-nistp256'] = <<-'EOB'
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIFFtGZHk6A8anZkLCJan9YBlB63uCIN/ZcQNCaJout8loAoGCCqGSM49
AwEHoUQDQgAEk8m548Xga+XGEmRx7P71xGlxCfgjPj3XVOw+fXPXRgA03a5yDJEp
OfeosJOO9twerD7pPhmXREkygblPsEXaVA==
-----END EC PRIVATE KEY-----
EOB

options['authentication_none_authenticator']      = auth_none
options['authentication_publickey_authenticator'] = auth_publickey
options['authentication_password_authenticator']  = auth_password

options['connection_channel_request_pty_req']       = HrrRbSsh::Connection::RequestHandler::ReferencePtyReqRequestHandler.new
options['connection_channel_request_env']           = HrrRbSsh::Connection::RequestHandler::ReferenceEnvRequestHandler.new
options['connection_channel_request_shell']         = HrrRbSsh::Connection::RequestHandler::ReferenceShellRequestHandler.new
options['connection_channel_request_exec']          = HrrRbSsh::Connection::RequestHandler::ReferenceExecRequestHandler.new
options['connection_channel_request_window_change'] = HrrRbSsh::Connection::RequestHandler::ReferenceWindowChangeRequestHandler.new


server = TCPServer.new 10022
while true
  t = Thread.new(server.accept) do |io|
    tran = HrrRbSsh::Transport.new      io, HrrRbSsh::Transport::Mode::SERVER, options
    auth = HrrRbSsh::Authentication.new tran, options
    conn = HrrRbSsh::Connection.new     auth, options
    conn.start
    io.close
  end
end
