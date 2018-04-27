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


tran_preferred_encryption_algorithms      = %w(aes128-ctr aes192-ctr aes256-ctr aes128-cbc 3des-cbc blowfish-cbc cast128-cbc aes192-cbc aes256-cbc arcfour)
tran_preferred_server_host_key_algorithms = %w(ecdsa-sha2-nistp521 ecdsa-sha2-nistp384 ecdsa-sha2-nistp256 ssh-rsa ssh-dss)
tran_preferred_kex_algorithms             = %w(ecdh-sha2-nistp521 ecdh-sha2-nistp384 ecdh-sha2-nistp256 diffie-hellman-group14-sha1 diffie-hellman-group1-sha1)
tran_preferred_mac_algorithms             = %w(hmac-sha2-512 hmac-sha2-256 hmac-sha1 hmac-md5 hmac-sha1-96 hmac-md5-96)
tran_preferred_compression_algorithms     = %w(none zlib)

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
  ecdsa_sha2_nistp256_public_key_algorithm_name = 'ecdsa-sha2-nistp256'
  ecdsa_sha2_nistp256_public_key = <<-'EOB'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE9DPmu6CIA5VCBaN9wpUP2UUZQ+dw
77mTZ7lD+z5cjzF7OL/cPL1/zklAsYaH7z7OcPYRbe24QCG5YfJQZjevJQ==
-----END PUBLIC KEY-----
  EOB
  [
    [dss_public_key_algorithm_name, dss_public_key],
    [rsa_public_key_algorithm_name, rsa_public_key],
    [ecdsa_sha2_nistp256_public_key_algorithm_name, ecdsa_sha2_nistp256_public_key],
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


options = {}

options['transport_preferred_encryption_algorithms']      = tran_preferred_encryption_algorithms
options['transport_preferred_server_host_key_algorithms'] = tran_preferred_server_host_key_algorithms
options['transport_preferred_kex_algorithms']             = tran_preferred_kex_algorithms
options['transport_preferred_mac_algorithms']             = tran_preferred_mac_algorithms
options['transport_preferred_compression_algorithms']     = tran_preferred_compression_algorithms

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
