require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp521 < ServerHostKeyAlgorithm
        NAME = 'ecdsa-sha2-nistp521'
        PREFERENCE = 50
        IDENTIFIER = 'nistp521'
        SECRET_KEY = OpenSSL::PKey::EC.generate('secp521r1').to_pem

        include Functionable
      end
    end
  end
end
