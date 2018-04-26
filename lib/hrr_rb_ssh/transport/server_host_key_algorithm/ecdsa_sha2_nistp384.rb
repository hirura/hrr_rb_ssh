# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp384 < ServerHostKeyAlgorithm
        NAME = 'ecdsa-sha2-nistp384'
        PREFERENCE = 40
        DIGEST = 'sha384'
        IDENTIFIER = 'nistp384'
        SECRET_KEY = <<-EOB
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDCKZ6ulBka9rUw+gqKiQdVBG6fzH1klswyMrxrzCcfwRfoc5CGnj8e7
emk+IHyUsd6gBwYFK4EEACKhZANiAATnWMWRgfp3DFiBmdT7LunyBk9YIBYqPsrk
Zil+AWvlISusiW2JcZVB+Hz79tyrgzfwp6n6k9r5s31EIGTGf/n7UMwISrUCfcx+
xVrnYV8pOoy+dcUiGb9okf1jc41bLHc=
-----END EC PRIVATE KEY-----
        EOB

        def initialize
          @logger = HrrRbSsh::Logger.new(self.class.name)
          @algorithm = OpenSSL::PKey::EC.new SECRET_KEY
        end

        def server_public_host_key
          payload = {
            :'ecdsa-sha2-[identifier]' => self.class::NAME,
            :'[identifier]'            => self.class::IDENTIFIER,
            :'Q'                       => @algorithm.public_key.to_bn.to_s(2)
          }
          PublicKeyBlob.encode payload
        end

        def ecdsa_signature_blob data
          hash = OpenSSL::Digest.digest(self.class::DIGEST, data)
          sign_der = @algorithm.dsa_sign_asn1(hash)
          sign_asn1 = OpenSSL::ASN1.decode(sign_der)
          r = sign_asn1.value[0].value.to_i
          s = sign_asn1.value[1].value.to_i
          payload = {
            :'r' => r,
            :'s' => s,
          }
          EcdsaSignatureBlob.encode payload
        end

        def sign data
          payload = {
            :'ecdsa-sha2-[identifier]' => self.class::NAME,
            :'ecdsa_signature_blob'    => ecdsa_signature_blob(data),
          }
          Signature.encode payload
        end

        def verify sign, data
          payload = Signature.decode sign
          ecdsa_signature_blob = EcdsaSignatureBlob.decode payload[:'ecdsa_signature_blob']
          r = ecdsa_signature_blob[:'r']
          s = ecdsa_signature_blob[:'s']
          sign_asn1 = OpenSSL::ASN1::Sequence.new(
            [
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(r)),
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(s)),
            ]
          )
          sign_der = sign_asn1.to_der
          hash = OpenSSL::Digest.digest(self.class::DIGEST, data)
          payload[:'ecdsa-sha2-[identifier]'] == self.class::NAME && @algorithm.dsa_verify_asn1(hash, sign_der)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp384/public_key_blob'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp384/ecdsa_signature_blob'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp384/signature'
