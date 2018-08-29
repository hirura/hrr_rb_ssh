# coding: utf-8
# vim: et ts=2 sw=2

require 'base64'
require 'ed25519'
require 'hrr_rb_ssh/logger'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshEd25519 < Publickey
        NAME = 'ssh-ed25519'

        def initialize arg
          case arg
          when ::Ed25519::SigningKey
            @publickey = arg
            @public_key_blob = @publickey.verify_key.to_bytes
          when ::String
            begin
              new_by_key_str arg
            rescue #OpenSSL::PKey::DSAError
              new_by_public_key_blob arg
            end
          else
            raise "Unexpected SshEd25519 argument: #{arg.inspect}"
          end
        end

        def new_by_key_str key_str
          if Base64.decode64(key_str.split("\n").select{|l| ! l.match(/-----[^-]+-----/)}.join("\n")) =~ /^openssh-key-v1.+/
            @publickey = new_by_openssh_key_str
          else
            raise "Unsupported ed25519 private key format"
          end
        end

        def new_by_openssh_key_str
          ::Ed25519::SigningKey.from_keypair(key_str)
        end

        def new_by_public_key_blob public_key_blob
          public_key_blob_h = PublicKeyBlob.decode(public_key_blob)
          @publickey = ::Ed25519::VerifyKey.new(public_key_blob_h[:key])
          @public_key_blob = public_key_blob
        end

        def to_pem
          @public_key_blob
        end

        def to_public_key_blob
          key = case @publickey
                when ::Ed25519::SigningKey
                  @publickey.verify_key.to_bytes
                when ::Ed25519::VerifyKey
                  @publickey.to_bytes
                end
          public_key_blob_h = {
            :'public key algorithm name' => self.class::NAME,
            :'key'                       => key
          }
          PublicKeyBlob.encode(public_key_blob_h)
        end

        def sign signature_blob
          sign = @publickey.sign(signature_blob)
          signature_h = {
            :'public key algorithm name' => self.class::NAME,
            :'signature blob'            => sign,
          }
          Signature.encode signature_h
        end

        def verify signature, signature_blob
          signature_h = Signature.decode signature
          begin
            signature_h[:'public key algorithm name'] == self.class::NAME && @publickey.verify(signature_h[:'signature blob'], signature_blob)
          rescue ::Ed25519::VerifyError
            false
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/public_key_blob'
require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/signature'
