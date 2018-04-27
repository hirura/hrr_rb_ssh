# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class EcdsaSha2Nistp384 < Algorithm
            NAME = 'ecdsa-sha2-nistp384'
            PREFERENCE = 40
            DIGEST = 'sha384'
            IDENTIFIER = 'nistp384'
            CURVE_NAME = 'secp384r1'

            def initialize
              @logger = HrrRbSsh::Logger.new(self.class.name)
            end

            def verify_public_key public_key_algorithm_name, public_key, public_key_blob
              public_key = case public_key
                           when String
                             OpenSSL::PKey::EC.new(public_key)
                           when OpenSSL::PKey::EC
                             public_key
                           else
                             return false
                           end
              public_key_message = {
                :'public key algorithm name' => public_key_algorithm_name,
                :'[identifier]'              => self.class::IDENTIFIER,
                :'Q'                         => public_key.public_key.to_bn.to_s(2)
              }
              public_key_blob == PublicKeyBlob.encode(public_key_message)
            end

            def verify_signature session_id, message
              signature_message   = Signature.decode message[:'signature']
              signature_algorithm = signature_message[:'public key algorithm name']
              signature_blob      = signature_message[:'signature blob']

              public_key = PublicKeyBlob.decode message[:'public key blob']
              algorithm = OpenSSL::PKey::EC.new(self.class::CURVE_NAME)
              algorithm.public_key = OpenSSL::PKey::EC::Point.new(algorithm.group, OpenSSL::BN.new(public_key[:'Q'], 2))

              data_message = {
                :'session identifier'        => session_id,
                :'message number'            => message[:'message number'],
                :'user name'                 => message[:'user name'],
                :'service name'              => message[:'service name'],
                :'method name'               => message[:'method name'],
                :'with signature'            => message[:'with signature'],
                :'public key algorithm name' => message[:'public key algorithm name'],
                :'public key blob'           => message[:'public key blob'],
              }
              data_blob = SignatureBlob.encode data_message

              hash = OpenSSL::Digest.digest(DIGEST, data_blob)
              ecdsa_signature_blob = EcdsaSignatureBlob.decode signature_blob
              sign_r = ecdsa_signature_blob[:'r']
              sign_s = ecdsa_signature_blob[:'s']
              sign_asn1 = OpenSSL::ASN1::Sequence.new(
                [
                  OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_r)),
                  OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_s)),
                ]
              )
              sign_der = sign_asn1.to_der
              (signature_algorithm == message[:'public key algorithm name']) && algorithm.dsa_verify_asn1(hash, sign_der)
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp384/public_key_blob'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp384/signature_blob'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp384/signature'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp384/ecdsa_signature_blob'
