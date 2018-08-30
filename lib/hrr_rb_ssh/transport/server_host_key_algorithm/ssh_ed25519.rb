# coding: utf-8
# vim: et ts=2 sw=2

require 'ed25519'
require 'hrr_rb_ssh/openssl_secure_random'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/functionable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshEd25519 < ServerHostKeyAlgorithm
        NAME = 'ssh-ed25519'
        PREFERENCE = 60
        SECRET_KEY = ::Ed25519::SigningKey.generate

        include Functionable
      end
    end
  end
end
