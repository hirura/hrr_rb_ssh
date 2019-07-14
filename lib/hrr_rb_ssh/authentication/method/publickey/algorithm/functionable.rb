# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/algorithm/publickey'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          module Functionable
            def initialize
              @logger = Logger.new(self.class.name)
            end

            def verify_public_key public_key_algorithm_name, public_key, public_key_blob
              begin
                publickey = HrrRbSsh::Algorithm::Publickey[self.class::NAME].new public_key
                public_key_algorithm_name == self.class::NAME && public_key_blob == publickey.to_public_key_blob
              rescue => e
                @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                false
              end
            end

            def verify_signature session_id, message
              begin
                signature_blob_h = {
                  :'session identifier'        => session_id,
                  :'message number'            => message[:'message number'],
                  :'user name'                 => message[:'user name'],
                  :'service name'              => message[:'service name'],
                  :'method name'               => message[:'method name'],
                  :'with signature'            => message[:'with signature'],
                  :'public key algorithm name' => message[:'public key algorithm name'],
                  :'public key blob'           => message[:'public key blob'],
                }
                signature_blob = SignatureBlob.encode signature_blob_h
                publickey = HrrRbSsh::Algorithm::Publickey[self.class::NAME].new message[:'public key blob']
                publickey.verify message[:'signature'], signature_blob
              rescue => e
                @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                false
              end
            end

            def generate_public_key_blob secret_key
              publickey = HrrRbSsh::Algorithm::Publickey[self.class::NAME].new secret_key
              publickey.to_public_key_blob
            end

            def generate_signature session_id, username, service_name, method_name, secret_key
              publickey = HrrRbSsh::Algorithm::Publickey[self.class::NAME].new secret_key
              publickey_blob = publickey.to_public_key_blob
              signature_blob_h = {
                :'session identifier'        => session_id,
                :'message number'            => Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
                :'user name'                 => username,
                :'service name'              => service_name,
                :'method name'               => method_name,
                :'with signature'            => true,
                :'public key algorithm name' => self.class::NAME,
                :'public key blob'           => publickey_blob
              }
              signature_blob = SignatureBlob.encode signature_blob_h
              publickey.sign signature_blob
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/signature_blob'
