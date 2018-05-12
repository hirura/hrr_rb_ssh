# coding: utf-8
# vim: et ts=2 sw=2

require 'etc'
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

            context.chain_proc { |chain|
              passwd = Etc.getpwnam(context.username)

              env = context.vars.fetch(:env, Hash.new)
              env['USER']  = passwd.name
              env['HOME']  = passwd.dir
              env['SHELL'] = passwd.shell

              program = [passwd.shell, passwd.shell.split('/').last.sub(/^/,'-')]

              args = Array.new

              options = Hash.new
              options[:unsetenv_others] = true
              options[:close_others] = true

              pid = fork do
                ptm.close
                Process.setsid
                Dir.chdir passwd.dir
                Process.gid  = passwd.gid
                Process.egid = passwd.gid
                Process.uid  = passwd.uid
                Process.euid = passwd.uid
                STDIN.reopen  pts, 'r'
                STDOUT.reopen pts, 'w'
                STDERR.reopen pts, 'w'
                pts.close
                exec env, program, *args, options
              end

              pts.close

              ptm_read_thread = Thread.start {
                loop do
                  begin
                    context.io[1].write ptm.readpartial(10240)
                  rescue EOFError => e
                    context.logger.info { "ptm is EOF in ptm_read_thread" }
                    break
                  rescue IOError => e
                    context.logger.warn { "IO Error in ptm_read_thread" }
                    break
                  rescue Errno::EIO => e
                    context.logger.info { "EIO Error in ptm_read_thread" }
                    break
                  rescue => e
                    context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                    break
                  end
                end
              }
              ptm_write_thread = Thread.start {
                loop do
                  begin
                    ptm.write context.io[0].readpartial(10240)
                  rescue EOFError => e
                    context.logger.info { "IO is EOF in ptm_write_thread" }
                    break
                  rescue IOError => e
                    context.logger.warn { "IO Error in ptm_write_thread" }
                    break
                  rescue Errno::EIO => e
                    context.logger.info { "EIO Error in ptm_read_thread" }
                    break
                  rescue => e
                    context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                    break
                  end
                end
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
                begin
                  ptm_read_thread.join
                rescue => e
                  context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                end
                begin
                  ptm_write_thread.exit
                  ptm_write_thread.join
                rescue => e
                  context.logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
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
