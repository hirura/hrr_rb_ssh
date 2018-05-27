# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Authentication
    class Method
      class None < Method
        NAME = 'none'
        PREFERENCE = 0

        def initialize transport, options
          @logger = Logger.new(self.class.name)
          @authenticator = options.fetch( 'authentication_none_authenticator', Authenticator.new { false } )
        end

        def authenticate userauth_request_message
          @logger.info { "authenticate" }
          @logger.debug { "userauth request: " + userauth_request_message.inspect }
          context = Context.new(userauth_request_message[:'user name'])
          @authenticator.authenticate context
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/none/context'
