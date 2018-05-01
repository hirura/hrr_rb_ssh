# coding: utf-8
# vim: et ts=2 sw=2

require 'timeout'
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

            context.io[2].close # never use err output in shell handler

            context.chain_proc { |chain|
              pid = fork do
                ptm.close
                Process.setsid
                STDIN.reopen  pts, 'r'
                STDOUT.reopen pts, 'w'
                STDERR.reopen pts, 'w'
                pts.close
                context.vars[:env] ||= Hash.new
                exec context.vars[:env], 'login', '-pf', context.username
              end

              pts.close

              threads = []
              threads.push Thread.start {
                loop do
                  begin
                    context.io[1].write ptm.readpartial(1024)
                  rescue EOFError => e
                    context.logger.info { "ptm is EOF" }
                    break
                  rescue IOError => e
                    context.logger.warn { "IO is closed" }
                    break
                  rescue => e
                    context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                    break
                  end
                end
                context.io[1].close
              }
              threads.push Thread.start {
                loop do
                  begin
                    ptm.write context.io[0].readpartial(1024)
                  rescue EOFError => e
                    context.logger.info { "IO is EOF" }
                    break
                  rescue IOError => e
                    context.logger.warn { "IO is closed" }
                    break
                  rescue => e
                    context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                    break
                  end
                end
                ptm.close
              }

              begin
                pid, status = Process.waitpid2 pid
                context.logger.info { "shell exited with status #{status.inspect}" }
                status.exitstatus
              ensure
                unless status
                  context.logger.info { "exiting shell" }
                  Process.kill :TERM, pid
                  begin
                    Timeout.timeout(1) do
                      pid, status = Process.waitpid2 pid
                    end
                  rescue Timeout::Error
                    context.logger.warn { "force exiting shell" }
                    Process.kill :KILL, pid
                    pid, status = Process.waitpid2 pid
                  end
                  context.logger.info { "shell exited with status #{status.inspect}" }
                end
                threads.each do |t|
                  begin
                    t.exit
                    t.join
                  rescue => e
                    context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                  end
                end
                context.logger.info { "proc chain finished" }
              end
            }
          }
        end
      end
    end
  end
end
