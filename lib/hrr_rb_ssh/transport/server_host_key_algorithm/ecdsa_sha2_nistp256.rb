require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp256 < ServerHostKeyAlgorithm
        NAME = 'ecdsa-sha2-nistp256'
        PREFERENCE = 30
        IDENTIFIER = 'nistp256'
        SECRET_KEY = OpenSSL::PKey::EC.generate('prime256v1').to_pem

        include Functionable
      end
    end
  end
end
