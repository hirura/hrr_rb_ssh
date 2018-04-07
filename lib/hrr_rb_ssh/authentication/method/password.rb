# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/authentication/method/method'

module HrrRbSsh
  class Authentication
    module Method
      class Password < Method
        NAME = 'password'

        def initialize options
          super

          @authenticator = options.fetch( 'authentication_password_authenticator', Authenticator.new { false } )
        end

        def authenticate userauth_request_message
          @logger.info("authenticate")
          @logger.debug("userauth request: " + userauth_request_message.inspect)
          username = userauth_request_message['user name']
          password = userauth_request_message['plaintext password']
          context = Context.new(username, password)
          @authenticator.authenticate context
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/password/context'
