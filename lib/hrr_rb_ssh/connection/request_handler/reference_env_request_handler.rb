# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferenceEnvRequestHandler < RequestHandler
        def initialize
          @proc = Proc.new { |context|
            context.vars[:env] ||= Hash.new
            context.vars[:env][context.variable_name] = context.variable_value
          }
        end
      end
    end
  end
end
