# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp256 < ServerHostKeyAlgorithm
        NAME = 'ecdsa-sha2-nistp256'
        PREFERENCE = 30
        DIGEST = 'sha256'
        IDENTIFIER = 'nistp256'
        SECRET_KEY = <<-EOB
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIB+8vCekxXfgw+Nz10ZykUGaI+X6ftdGG6b2UX2iz7oEoAoGCCqGSM49
AwEHoUQDQgAEt1em9ko6A2kZFFwVtKgQ0xpggZg17EJQmhFz7ObGNsZ8VIFEc0Hg
SpNC6qrqdhUfVAjsF9y5O/3Z/LGh/lNTig==
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
          tmp = PublicKeyBlob.encode payload
          p tmp.unpack("H*")[0]
          tmp
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

require 'hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp256/public_key_blob'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp256/ecdsa_signature_blob'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp256/signature'
