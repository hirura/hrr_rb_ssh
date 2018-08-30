# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshEd25519 < Publickey
        NAME = 'ssh-ed25519'

        def initialize arg
          begin
            new_by_key_str arg
          rescue PKey::Error
            new_by_public_key_blob arg
          end
        end

        def new_by_key_str key_str
          @publickey = PKey.new(key_str)
        end

        def new_by_public_key_blob public_key_blob
          public_key_blob_h = PublicKeyBlob.decode(public_key_blob)
          @publickey = PKey.new
          @publickey.set_public_key(public_key_blob_h[:key])
        end

        def to_pem
          @publickey.public_key.to_pem
        end

        def to_public_key_blob
          public_key_blob_h = {
            :'public key algorithm name' => self.class::NAME,
            :'key'                       => @publickey.public_key.key_str,
          }
          PublicKeyBlob.encode(public_key_blob_h)
        end

        def sign signature_blob
          signature_h = {
            :'public key algorithm name' => self.class::NAME,
            :'signature blob'            => @publickey.sign(signature_blob),
          }
          Signature.encode signature_h
        end

        def verify signature, signature_blob
          signature_h = Signature.decode signature
          signature_h[:'public key algorithm name'] == self.class::NAME && @publickey.public_key.verify(signature_h[:'signature blob'], signature_blob)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/pkey'
require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/public_key_blob'
require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/signature'
