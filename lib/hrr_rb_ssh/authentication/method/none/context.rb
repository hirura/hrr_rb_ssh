# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Authentication
    class Method
      class None
        class Context
          include Loggable

          attr_reader \
            :username,
            :variables,
            :vars,
            :authentication_methods

          def initialize username, variables, authentication_methods, logger: nil
            self.logger = logger
            @username = username
            @variables = variables
            @vars = variables
            @authentication_methods = authentication_methods
          end

          def verify username
            log_info { "verify username" }
            log_debug { "username is #{username}, @username is #{@username}" }
            username == @username
          end
        end
      end
    end
  end
end
