require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshRsa < ServerHostKeyAlgorithm
        NAME = 'ssh-rsa'
        PREFERENCE = 20
        SECRET_KEY = OpenSSL::PKey::RSA.new(2048).to_pem

        include Functionable
      end
    end
  end
end
