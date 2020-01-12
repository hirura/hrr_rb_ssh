# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshDss < Publickey
        include Loggable

        NAME = 'ssh-dss'
        DIGEST = 'sha1'

        def initialize arg, logger: nil
          self.logger = logger
          begin
            new_by_key_str arg
          rescue OpenSSL::PKey::DSAError
            new_by_public_key_blob arg
          end
        end

        def new_by_key_str key_str
          @publickey = OpenSSL::PKey::DSA.new(key_str)
        end

        def new_by_public_key_blob public_key_blob
          public_key_blob_h = PublicKeyBlob.new(logger: logger).decode public_key_blob
          @publickey = OpenSSL::PKey::DSA.new
          if @publickey.respond_to?(:set_pqg)
            @publickey.set_pqg public_key_blob_h[:'p'], public_key_blob_h[:'q'], public_key_blob_h[:'g']
          else
            @publickey.p = public_key_blob_h[:'p']
            @publickey.q = public_key_blob_h[:'q']
            @publickey.g = public_key_blob_h[:'g']
          end
          if @publickey.respond_to?(:set_key)
            @publickey.set_key public_key_blob_h[:'y'], nil
          else
            @publickey.pub_key = public_key_blob_h[:'y']
          end
        end

        def to_pem
          @publickey.public_key.to_pem
        end

        def to_public_key_blob
          public_key_blob_h = {
            :'public key algorithm name' => self.class::NAME,
            :'p'                         => @publickey.p.to_i,
            :'q'                         => @publickey.q.to_i,
            :'g'                         => @publickey.g.to_i,
            :'y'                         => @publickey.pub_key.to_i,
          }
          PublicKeyBlob.new(logger: logger).encode public_key_blob_h
        end

        def sign signature_blob
          hash = OpenSSL::Digest.digest(self.class::DIGEST, signature_blob)
          sign_der = @publickey.syssign(hash)
          sign_asn1 = OpenSSL::ASN1.decode sign_der
          sign_r = sign_asn1.value[0].value.to_s(2).rjust(20, ["00"].pack("H"))
          sign_s = sign_asn1.value[1].value.to_s(2).rjust(20, ["00"].pack("H"))
          signature_h = {
            :'public key algorithm name' => self.class::NAME,
            :'signature blob'            => (sign_r + sign_s),
          }
          Signature.new(logger: logger).encode signature_h
        end

        def verify signature, signature_blob
          signature_h = Signature.new(logger: logger).decode signature
          sign_r = signature_h[:'signature blob'][ 0, 20]
          sign_s = signature_h[:'signature blob'][20, 20]
          sign_asn1 = OpenSSL::ASN1::Sequence.new(
            [
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_r, 2)),
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_s, 2)),
            ]
          )
          sign_der = sign_asn1.to_der
          hash = OpenSSL::Digest.digest(self.class::DIGEST, signature_blob)
          signature_h[:'public key algorithm name'] == self.class::NAME && @publickey.sysverify(hash, sign_der)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_dss/public_key_blob'
require 'hrr_rb_ssh/algorithm/publickey/ssh_dss/signature'
