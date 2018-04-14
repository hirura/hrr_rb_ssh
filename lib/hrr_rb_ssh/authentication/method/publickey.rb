# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey < Method
        NAME = 'publickey'
        PREFERENCE = 20

        def initialize options
          @logger = HrrRbSsh::Logger.new(self.class.name)
          @session_id = options['session id']
          @authenticator = options.fetch( 'authentication_publickey_authenticator', Authenticator.new { false } )
        end

        def authenticate userauth_request_message
          public_key_algorithm_name = userauth_request_message['public key algorithm name']
          unless Algorithm.name_list.include?(public_key_algorithm_name)
            @logger.info("unsupported public key algorithm: #{public_key_algorithm_name}")
            return false
          end
          unless userauth_request_message['with signature']
            @logger.info("public key algorithm is ok, require signature")
            public_key_blob = userauth_request_message['public key blob']
            userauth_pk_ok_message public_key_algorithm_name, public_key_blob
          else
            @logger.info("verify signature")
            username = userauth_request_message['user name']
            algorithm = Algorithm[public_key_algorithm_name].new
            context = Context.new(username, algorithm, @session_id, userauth_request_message)
            @authenticator.authenticate context
          end
        end

        def userauth_pk_ok_message public_key_algorithm_name, public_key_blob
          message = {
            'message number'                             => HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
            'public key algorithm name from the request' => public_key_algorithm_name,
            'public key blob from the request'           => public_key_blob,
          }
          payload = HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK.encode message
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/context'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm'
