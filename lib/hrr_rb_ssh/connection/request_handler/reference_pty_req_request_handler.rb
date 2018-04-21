# coding: utf-8
# vim: et ts=2 sw=2

require 'io/console'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferencePtyReqRequestHandler < RequestHandler
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
          @proc = Proc.new { |context|
            ptm, pts = PTY.open
            ptm.winsize = [context.terminal_height_rows, context.terminal_width_characters]
            context.vars[:ptm] = ptm
            context.vars[:pts] = pts
            context.chain_proc { |chain|
              begin
                chain.call_next
              ensure
                context.vars[:ptm].close
                context.vars[:pts].close
              end
            }
          }
        end
      end
    end
  end
end
