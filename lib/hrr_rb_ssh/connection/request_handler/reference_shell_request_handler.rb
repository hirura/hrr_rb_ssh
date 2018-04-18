# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferenceShellRequestHandler < RequestHandler
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
          @proc = Proc.new { |context|
            ptm = context.vars[:ptm]
            pts = context.vars[:pts]

            context.chain_proc { |chain|
              pid = fork do
                ptm.close
                Process.setsid
                STDIN.reopen  pts, 'r'
                STDOUT.reopen pts, 'w'
                STDERR.reopen pts, 'w'
                pts.close
                context.vars[:env] ||= Hash.new
                exec context.vars[:env], 'login', '-f', context.username
              end

              pts.close

              threads = []
              threads.push Thread.start {
                loop do
                  begin
                    context.io.write ptm.readpartial(1024)
                  rescue EOFError => e
                    context.logger.info("ptm is EOF")
                    break
                  rescue IOError => e
                    context.logger.warn("IO is closed")
                    break
                  rescue => e
                    context.logger.error(e.full_message)
                    break
                  end
                end
              }
              threads.push Thread.start {
                loop do
                  begin
                    ptm.write context.io.readpartial(1024)
                  rescue EOFError => e
                    context.logger.info("IO is EOF")
                    break
                  rescue IOError => e
                    context.logger.warn("IO is closed")
                    break
                  rescue => e
                    context.logger.error(e.full_message)
                    break
                  end
                end
              }

              pid, status = Process.waitpid2 pid
              threads.each do |t|
                begin
                  t.exit
                  t.join
                rescue => e
                  context.logger.error(e.full_message)
                end
              end
              status.exitstatus
            }
          }
        end
      end
    end
  end
end
