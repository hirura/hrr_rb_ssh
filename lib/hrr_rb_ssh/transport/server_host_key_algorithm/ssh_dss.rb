require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshDss < ServerHostKeyAlgorithm
        NAME = 'ssh-dss'
        PREFERENCE = 10
        SECRET_KEY = OpenSSL::PKey::DSA.new(1024).to_pem

        include Functionable
      end
    end
  end
end
