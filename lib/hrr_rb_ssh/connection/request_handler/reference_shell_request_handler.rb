# coding: utf-8
# vim: et ts=2 sw=2

require 'etc'
require 'timeout'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferenceShellRequestHandler < RequestHandler
        def initialize
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
                Process::GID.change_privilege passwd.gid
                Process::UID.change_privilege passwd.uid
                STDIN.reopen  pts, 'r'
                STDOUT.reopen pts, 'w'
                STDERR.reopen pts, 'w'
                pts.close
                exec env, program, *args, options
              end

              pts.close

              begin
                pid, status = Process.waitpid2 pid
                context.log_info { "shell exited with status #{status.inspect}" }
                status.exitstatus
              ensure
                unless status
                  context.log_info { "exiting shell" }
                  Process.kill :TERM, pid
                  begin
                    Timeout.timeout(1) do
                      pid, status = Process.waitpid2 pid
                    end
                  rescue Timeout::Error
                    context.log_warn { "force exiting shell" }
                    Process.kill :KILL, pid
                    pid, status = Process.waitpid2 pid
                  end
                  context.log_info { "shell exited with status #{status.inspect}" }
                end
              end
            }
          }
        end
      end
    end
  end
end
