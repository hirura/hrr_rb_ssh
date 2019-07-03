# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Authentication
    class Method
      class None
        class Context
          attr_reader \
            :username,
            :variables,
            :vars,
            :authentication_methods

          def initialize username, variables, authentication_methods
            @username = username
            @variables = variables
            @vars = variables
            @authentication_methods = authentication_methods

            @logger = Logger.new self.class.name
          end

          def verify username
            @logger.info { "verify username" }
            @logger.debug { "username is #{username}, @username is #{@username}" }
            username == @username
          end
        end
      end
    end
  end
end
