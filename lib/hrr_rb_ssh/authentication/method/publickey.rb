# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey < Method
        include Loggable

        NAME = 'publickey'
        PREFERENCE = 20

        def initialize transport, options, variables, authentication_methods, logger: nil
          self.logger = logger
          @transport = transport
          @options = options
          @session_id = options['session id']
          @authenticator = options.fetch( 'authentication_publickey_authenticator', Authenticator.new{ false } )
          @variables = variables
          @authentication_methods = authentication_methods
        end

        def authenticate userauth_request_message
          public_key_algorithm_name = userauth_request_message[:'public key algorithm name']
          unless Algorithm.list_preferred.include?(public_key_algorithm_name)
            log_info { "unsupported public key algorithm: #{public_key_algorithm_name}" }
            return false
          end
          unless userauth_request_message[:'with signature']
            log_info { "public key algorithm is ok, require signature" }
            public_key_blob = userauth_request_message[:'public key blob']
            userauth_pk_ok_message public_key_algorithm_name, public_key_blob
          else
            log_info { "verify signature" }
            username = userauth_request_message[:'user name']
            algorithm = Algorithm[public_key_algorithm_name].new logger: logger
            context = Context.new(username, algorithm, @session_id, userauth_request_message, @variables, @authentication_methods, logger: logger)
            @authenticator.authenticate context
          end
        end

        def userauth_pk_ok_message public_key_algorithm_name, public_key_blob
          message = {
            :'message number'                             => Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
            :'public key algorithm name from the request' => public_key_algorithm_name,
            :'public key blob from the request'           => public_key_blob,
          }
          payload = Message::SSH_MSG_USERAUTH_PK_OK.new(logger: logger).encode message
        end

        def request_authentication username, service_name
          public_key_algorithm_name, secret_key = @options['client_authentication_publickey']
          send_request_without_signature username, service_name, public_key_algorithm_name, secret_key
          payload = @transport.receive
          case payload[0,1].unpack("C")[0]
          when Message::SSH_MSG_USERAUTH_PK_OK::VALUE
            send_request_with_signature username, service_name, public_key_algorithm_name, secret_key
            @transport.receive
          else
            payload
          end
        end

        def send_request_without_signature username, service_name, public_key_algorithm_name, secret_key
          algorithm = Algorithm[public_key_algorithm_name].new logger: logger
          public_key_blob = algorithm.generate_public_key_blob(secret_key)
          message = {
            :'message number'            => Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
            :"user name"                 => username,
            :"service name"              => service_name,
            :"method name"               => NAME,
            :"with signature"            => false,
            :'public key algorithm name' => public_key_algorithm_name,
            :'public key blob'           => public_key_blob,
          }
          payload = Message::SSH_MSG_USERAUTH_REQUEST.new(logger: logger).encode message
          @transport.send payload
        end

        def send_request_with_signature username, service_name, public_key_algorithm_name, secret_key
          algorithm = Algorithm[public_key_algorithm_name].new logger: logger
          public_key_blob = algorithm.generate_public_key_blob(secret_key)
          signature = algorithm.generate_signature(@session_id, username, service_name, 'publickey', secret_key)
          message = {
            :'message number'            => Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
            :"user name"                 => username,
            :"service name"              => service_name,
            :"method name"               => NAME,
            :"with signature"            => true,
            :'public key algorithm name' => public_key_algorithm_name,
            :'public key blob'           => public_key_blob,
            :'signature'                 => signature,
          }
          payload = Message::SSH_MSG_USERAUTH_REQUEST.new(logger: logger).encode message
          @transport.send payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/context'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm'
