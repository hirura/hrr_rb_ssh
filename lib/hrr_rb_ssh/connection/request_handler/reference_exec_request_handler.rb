# coding: utf-8
# vim: et ts=2 sw=2

require 'etc'
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
              passwd = Etc.getpwnam(context.username)

              env = context.vars.fetch(:env, Hash.new)
              env['USER']  = passwd.name
              env['HOME']  = passwd.dir
              env['SHELL'] = passwd.shell

              program = context.command

              args = Array.new

              options = Hash.new
              options[:unsetenv_others] = true
              options[:close_others] = true
              options[:in]  = context.io[0]
              options[:out] = context.io[1]
              options[:err] = context.io[2]

              pid = fork do
                Process.setsid
                Dir.chdir passwd.dir
                Process.gid  = passwd.gid
                Process.egid = passwd.gid
                Process.uid  = passwd.uid
                Process.euid = passwd.uid
                exec env, program, *args, options
              end
              pid, status = Process.waitpid2 pid
              status.exitstatus
            }
          }
        end
      end
    end
  end
end
