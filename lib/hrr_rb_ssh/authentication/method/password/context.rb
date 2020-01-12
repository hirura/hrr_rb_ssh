# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Authentication
    class Method
      class Password
        class Context
          include Loggable

          attr_reader \
            :username,
            :password,
            :variables,
            :vars,
            :authentication_methods

          def initialize username, password, variables, authentication_methods, logger: nil
            self.logger = logger
            @username = username
            @password = password
            @variables = variables
            @vars = variables
            @authentication_methods = authentication_methods
          end

          def verify username, password
            log_info { "verify username and password" }
            log_debug { "username is #{username}, @username is #{@username}, and password is #{password}, @password is #{@password}" }
            username == @username and password == @password
          end
        end
      end
    end
  end
end
