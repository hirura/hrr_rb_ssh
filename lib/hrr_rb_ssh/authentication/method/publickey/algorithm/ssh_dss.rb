# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SshDss < Algorithm
            NAME = 'ssh-dss'
            PREFERENCE = 10
            DIGEST = 'sha1'

            def initialize
              @logger = Logger.new(self.class.name)
            end

            def verify_public_key public_key_algorithm_name, public_key, public_key_blob
              public_key = case public_key
                           when String
                             OpenSSL::PKey::DSA.new(public_key)
                           when OpenSSL::PKey::DSA
                             public_key
                           else
                             return false
                           end
              public_key_message = {
                :'public key algorithm name' => public_key_algorithm_name,
                :'p'                         => public_key.p.to_i,
                :'g'                         => public_key.g.to_i,
                :'q'                         => public_key.q.to_i,
                :'y'                         => public_key.pub_key.to_i,
              }
              public_key_blob == PublicKeyBlob.encode(public_key_message)
            end

            def verify_signature session_id, message
              signature_message   = Signature.decode message[:'signature']
              signature_algorithm = signature_message[:'public key algorithm name']
              signature_blob      = signature_message[:'signature blob']

              public_key = PublicKeyBlob.decode message[:'public key blob']
              algorithm = OpenSSL::PKey::DSA.new
              if algorithm.respond_to?(:set_pqg)
                algorithm.set_pqg public_key[:'p'], public_key[:'q'], public_key[:'g']
              else
                algorithm.p = public_key[:'p']
                algorithm.q = public_key[:'q']
                algorithm.g = public_key[:'g']
              end
              if algorithm.respond_to?(:set_key)
                algorithm.set_key public_key[:'y'], nil
              else
                algorithm.pub_key = public_key[:'y']
              end

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
              sign_r = signature_blob[ 0, 20]
              sign_s = signature_blob[20, 20]
              sign_asn1 = OpenSSL::ASN1::Sequence.new(
                [
                  OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_r, 2)),
                  OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_s, 2)),
                ]
              )
              sign_der = sign_asn1.to_der
              (signature_algorithm == message[:'public key algorithm name']) && algorithm.sysverify(hash, sign_der)
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_dss/public_key_blob'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_dss/signature_blob'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_dss/signature'
