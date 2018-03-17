# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/authentication/method/password/context'

module HrrRbSsh
  class Authentication
    module Method
      name_list = [
        'password'
      ]

      class Password
        def initialize options
          @logger = HrrRbSsh::Logger.new self.class.name

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

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = Password
      end
    end
  end
end
