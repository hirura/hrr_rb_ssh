# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    module Method
      class Publickey
        module Algorithm
          class SshRsa < Algorithm
            NAME   = 'ssh-rsa'
            DIGEST = 'sha1'

            PUBLIC_KEY_BLOB_DEFINITION = [
              ['string', 'public key algorithm name'],
              ['mpint',  'e'],
              ['mpint',  'n'],
            ]

            SIGNATURE_DEFINITION = [
              ['string', 'public key algorithm name'],
              ['string', 'signature blob'],
            ]

            SIGNATURE_BLOB_DEFINITION = [
              ['string',  'session identifier'],
              ['byte',    'message number'],
              ['string',  'user name'],
              ['string',  'service name'],
              ['string',  'method name'],
              ['boolean', 'with signature'],
              ['string',  'public key algorithm name'],
              ['string',  'public key blob'],
            ]

            def verify_public_key public_key_algorithm_name, public_key, public_key_blob
              public_key = case public_key
                           when String
                             OpenSSL::PKey::RSA.new(public_key)
                           when OpenSSL::PKey::RSA
                             public_key
                           else
                             return false
                           end
              public_key_message = {
                'public key algorithm name' => public_key_algorithm_name,
                'e'                         => public_key.e.to_i,
                'n'                         => public_key.n.to_i,
              }
              public_key_blob == encode(PUBLIC_KEY_BLOB_DEFINITION, public_key_message)
            end

            def verify_signature session_id, message
              signature_message   = decode SIGNATURE_DEFINITION, message['signature']
              signature_algorithm = signature_message['public key algorithm name']
              signature_blob      = signature_message['signature blob']

              public_key = decode PUBLIC_KEY_BLOB_DEFINITION, message['public key blob']
              algorithm = OpenSSL::PKey::RSA.new
              if algorithm.respond_to?(:set_key)
                algorithm.set_key public_key['n'], public_key['e'], nil
              else
                algorithm.e = public_key['e']
                algorithm.n = public_key['n']
              end

              data_message = {
                'session identifier'        => session_id,
                'message number'            => message['message number'],
                'user name'                 => message['user name'],
                'service name'              => message['service name'],
                'method name'               => message['method name'],
                'with signature'            => message['with signature'],
                'public key algorithm name' => message['public key algorithm name'],
                'public key blob'           => message['public key blob'],
              }
              data_blob = encode SIGNATURE_BLOB_DEFINITION, data_message

              (signature_algorithm == message['public key algorithm name']) && algorithm.verify(DIGEST, signature_blob, data_blob)
            end
          end
        end
      end
    end
  end
end
