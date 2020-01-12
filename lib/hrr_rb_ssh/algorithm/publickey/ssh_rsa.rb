# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshRsa < Publickey
        include Loggable

        NAME = 'ssh-rsa'
        DIGEST = 'sha1'

        def initialize arg, logger: nil
          self.logger = logger
          begin
            new_by_key_str arg
          rescue OpenSSL::PKey::RSAError
            new_by_public_key_blob arg
          end
        end

        def new_by_key_str key_str
          @publickey = OpenSSL::PKey::RSA.new(key_str)
        end

        def new_by_public_key_blob public_key_blob
          public_key_blob_h = PublicKeyBlob.new(logger: logger).decode public_key_blob
          @publickey = OpenSSL::PKey::RSA.new
          if @publickey.respond_to?(:set_key)
            @publickey.set_key public_key_blob_h[:'n'], public_key_blob_h[:'e'], nil
          else
            @publickey.n = public_key_blob_h[:'n']
            @publickey.e = public_key_blob_h[:'e']
          end
        end

        def to_pem
          @publickey.public_key.to_pem
        end

        def to_public_key_blob
          public_key_blob_h = {
            :'public key algorithm name' => self.class::NAME,
            :'e'                         => @publickey.e.to_i,
            :'n'                         => @publickey.n.to_i,
          }
          PublicKeyBlob.new(logger: logger).encode public_key_blob_h
        end

        def sign signature_blob
          signature_h = {
            :'public key algorithm name' => self.class::NAME,
            :'signature blob'            => @publickey.sign(self.class::DIGEST, signature_blob),
          }
          Signature.new(logger: logger).encode signature_h
        end

        def verify signature, signature_blob
          signature_h = Signature.new(logger: logger).decode signature
          signature_h[:'public key algorithm name'] == self.class::NAME && @publickey.verify(self.class::DIGEST, signature_h[:'signature blob'], signature_blob)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_rsa/public_key_blob'
require 'hrr_rb_ssh/algorithm/publickey/ssh_rsa/signature'
