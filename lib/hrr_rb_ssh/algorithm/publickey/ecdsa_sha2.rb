# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/data_type'

module HrrRbSsh
  module Algorithm
    class Publickey
      module EcdsaSha2
        include Loggable

        def initialize arg, logger: nil
          self.logger = logger
          begin
            new_by_key_str arg
          rescue OpenSSL::PKey::ECError
            new_by_public_key_blob arg
          end
        end

        def new_by_key_str key_str
          @publickey = OpenSSL::PKey::EC.new(key_str.delete(0.chr))
        end

        def new_by_public_key_blob public_key_blob
          public_key_blob_h = PublicKeyBlob.new(logger: logger).decode public_key_blob
          @publickey = OpenSSL::PKey::EC.new(self.class::CURVE_NAME)
          @publickey.public_key = OpenSSL::PKey::EC::Point.new(@publickey.group, OpenSSL::BN.new(public_key_blob_h[:'Q'], 2))
        end

        def to_pem
          @publickey.to_pem
        end

        def to_public_key_blob
          public_key_blob_h = {
            :'public key algorithm name' => self.class::NAME,
            :'identifier'                => self.class::IDENTIFIER,
            :'Q'                         => @publickey.public_key.to_bn.to_s(2)
          }
          PublicKeyBlob.new(logger: logger).encode public_key_blob_h
        end

        def ecdsa_signature_blob signature_blob
          hash = OpenSSL::Digest.digest(self.class::DIGEST, signature_blob)
          sign_der = @publickey.dsa_sign_asn1(hash)
          sign_asn1 = OpenSSL::ASN1.decode sign_der
          r = sign_asn1.value[0].value.to_i
          s = sign_asn1.value[1].value.to_i
          ecdsa_signature_blob_h = {
            :'r' => r,
            :'s' => s,
          }
          EcdsaSignatureBlob.new(logger: logger).encode ecdsa_signature_blob_h
        end

        def sign signature_blob
          signature_h = {
            :'public key algorithm name' => self.class::NAME,
            :'ecdsa signature blob'      => ecdsa_signature_blob(signature_blob),
          }
          Signature.new(logger: logger).encode signature_h
        end

        def verify signature, signature_blob
          signature_h = Signature.new(logger: logger).decode signature
          ecdsa_signature_blob_h = EcdsaSignatureBlob.new(logger: logger).decode signature_h[:'ecdsa signature blob']
          r = ecdsa_signature_blob_h[:'r']
          s = ecdsa_signature_blob_h[:'s']
          sign_asn1 = OpenSSL::ASN1::Sequence.new(
            [
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(r)),
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(s)),
            ]
          )
          sign_der = sign_asn1.to_der
          hash = OpenSSL::Digest.digest(self.class::DIGEST, signature_blob)
          signature_h[:'public key algorithm name'] == self.class::NAME && @publickey.dsa_verify_asn1(hash, sign_der)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2/public_key_blob'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2/signature'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2/ecdsa_signature_blob'
