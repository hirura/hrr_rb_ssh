# coding: utf-8
# vim: et ts=2 sw=2

require 'etc'
require 'fileutils'
require 'pty'
require 'io/console'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferencePtyReqRequestHandler < RequestHandler
        def initialize
          @logger = Logger.new self.class.name
          @proc = Proc.new { |context|
            begin
              ptm, pts = PTY.open
              passwd = Etc.getpwnam(context.username)
              FileUtils.chown passwd.uid, -1, pts
              FileUtils.chmod 'u+rw,g+w', pts
              ptm.winsize = [context.terminal_height_rows, context.terminal_width_characters, context.terminal_width_pixels, context.terminal_height_pixels]
              context.vars[:ptm] = ptm
              context.vars[:pts] = pts
              context.vars[:env] ||= Hash.new
              context.vars[:env]['TERM'] = context.term_environment_variable_value
              context.chain_proc { |chain|
                begin
                  chain.call_next
                ensure
                  begin
                    context.vars[:ptm].close
                  rescue
                  end
                  begin
                    context.vars[:pts].close
                  rescue
                  end
                end
              }
            rescue => e
              begin
                ptm.close
              rescue
              end
              begin
                pts.close
              rescue
              end
              context.chain_proc{ |chain|
                exitstatus = 1
              }
              raise e
            end
          }
        end
      end
    end
  end
end
