# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Context
          include Loggable

          attr_reader \
            :username,
            :session_id,
            :variables,
            :vars,
            :authentication_methods,
            :message_number,
            :service_name,
            :method_name,
            :with_signature,
            :public_key_algorithm_name,
            :public_key_blob,
            :signature

          def initialize username, algorithm, session_id, message, variables, authentication_methods, logger: nil
            self.logger = logger
            @username   = username
            @algorithm  = algorithm
            @session_id = session_id
            @message    = message
            @variables  = variables
            @vars       = variables
            @authentication_methods = authentication_methods

            @message_number            = message[:'message number']
            @service_name              = message[:'service name']
            @method_name               = message[:'method name']
            @with_signature            = message[:'with signature']
            @public_key_algorithm_name = message[:'public key algorithm name']
            @public_key_blob           = message[:'public key blob']
            @signature                 = message[:'signature']
          end

          def verify username, public_key_algorithm_name, public_key
              verify_username(username) \
              && verify_public_key_algorithm_name(public_key_algorithm_name) \
              && verify_public_key(public_key_algorithm_name, public_key) \
              && verify_signature
          end

          def verify_username username
            username == @username
          end

          def verify_public_key_algorithm_name public_key_algorithm_name
            public_key_algorithm_name == @public_key_algorithm_name
          end

          def verify_public_key public_key_algorithm_name, public_key
            @algorithm.verify_public_key(public_key_algorithm_name, public_key, @public_key_blob)
          end

          def verify_signature
            @algorithm.verify_signature(@session_id, @message)
          end
        end
      end
    end
  end
end
