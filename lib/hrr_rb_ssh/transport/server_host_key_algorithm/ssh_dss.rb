# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/openssl_secure_random'
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
