# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/authentication/method/none/context'

module HrrRbSsh
  class Authentication
    module Method
      name_list = [
        'none'
      ]

      class None
        def initialize options
          @logger = HrrRbSsh::Logger.new self.class.name

          @authenticator = options.fetch( 'authentication_none_authenticator', Authenticator.new { false } )
        end

        def authenticate userauth_request_message
          @logger.info("authenticate")
          @logger.debug("userauth request: " + userauth_request_message.inspect)
          context = Context.new(userauth_request_message['user name'])
          @authenticator.authenticate context
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = None
      end
    end
  end
end



