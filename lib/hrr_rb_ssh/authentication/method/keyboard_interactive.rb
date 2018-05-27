# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive < Method
        NAME = 'keyboard-interactive'
        PREFERENCE = 30

        def initialize transport, options
          @logger = Logger.new(self.class.name)
          @transport = transport
          @authenticator = options.fetch( 'authentication_keyboard_interactive_authenticator', Authenticator.new { false } )
        end

        def authenticate userauth_request_message
          @logger.info { "authenticate" }
          @logger.debug { "userauth request: " + userauth_request_message.inspect }
          username = userauth_request_message[:'user name']
          submethods = userauth_request_message[:'submethods']
          context = Context.new(@transport, username, submethods)
          @authenticator.authenticate context
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/keyboard_interactive/context'
