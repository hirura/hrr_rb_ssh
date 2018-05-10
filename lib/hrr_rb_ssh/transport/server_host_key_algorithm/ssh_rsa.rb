# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/openssl_secure_random'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshRsa < ServerHostKeyAlgorithm
        NAME = 'ssh-rsa'
        PREFERENCE = 20
        DIGEST = 'sha1'
        SECRET_KEY = OpenSSL::PKey::RSA.new(2048).to_pem

        def initialize secret_key=nil
          @logger = HrrRbSsh::Logger.new(self.class.name)
          @rsa = OpenSSL::PKey::RSA.new (secret_key || self.class::SECRET_KEY)
        end

        def server_public_host_key
          payload = {
            :'ssh-rsa' => "ssh-rsa",
            :'e'       => @rsa.e.to_i,
            :'n'       => @rsa.n.to_i,
          }
          PublicKeyBlob.encode payload
        end

        def sign data
          payload = {
            :'ssh-rsa'            => "ssh-rsa",
            :'rsa_signature_blob' => @rsa.sign(self.class::DIGEST, data),
          }
          Signature.encode payload
        end

        def verify sign, data
          payload = Signature.decode sign
          payload[:'ssh-rsa'] == "ssh-rsa" && @rsa.verify(self.class::DIGEST, payload[:'rsa_signature_blob'], data)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/server_host_key_algorithm/ssh_rsa/public_key_blob'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/ssh_rsa/signature'
