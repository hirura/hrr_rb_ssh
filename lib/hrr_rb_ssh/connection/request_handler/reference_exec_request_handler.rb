# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferenceExecRequestHandler < RequestHandler
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
          @proc = Proc.new { |context|
            context.chain_proc { |chain|
              pid = fork do
                Process.setsid
                context.vars[:env] ||= Hash.new
                exec context.vars[:env], context.command, in: context.io[0], out: context.io[1], err: context.io[2]
              end
              context.io.each{ |io| io.close }
              pid, status = Process.waitpid2 pid
              status.exitstatus
            }
          }
        end
      end
    end
  end
end
