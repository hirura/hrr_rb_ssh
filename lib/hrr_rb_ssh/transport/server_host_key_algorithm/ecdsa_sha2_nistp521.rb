# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/openssl_secure_random'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp521 < ServerHostKeyAlgorithm
        NAME = 'ecdsa-sha2-nistp521'
        PREFERENCE = 50
        IDENTIFIER = 'nistp521'
        SECRET_KEY = OpenSSL::PKey::EC.new('secp521r1').generate_key.to_pem

        include Functionable
      end
    end
  end
end
