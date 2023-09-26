require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp384 < ServerHostKeyAlgorithm
        NAME = 'ecdsa-sha2-nistp384'
        PREFERENCE = 40
        IDENTIFIER = 'nistp384'
        SECRET_KEY = OpenSSL::PKey::EC.generate('secp384r1').to_pem

        include Functionable
      end
    end
  end
end
