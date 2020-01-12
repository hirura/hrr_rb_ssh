# coding: utf-8
# vim: et ts=2 sw=2

require 'etc'
require 'fileutils'
require 'pty'
require 'io/console'
require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class RequestHandler
      class ReferencePtyReqRequestHandler < RequestHandler
        def initialize
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
                  ptm_read_thread = Thread.start {
                    loop do
                      begin
                        context.io[1].write ptm.readpartial(10240)
                      rescue EOFError => e
                        context.log_info { "ptm is EOF in ptm_read_thread" }
                        break
                      rescue IOError => e
                        context.log_warn { "IO Error in ptm_read_thread" }
                        break
                      rescue Errno::EIO => e
                        context.log_info { "EIO Error in ptm_read_thread" }
                        break
                      rescue => e
                        context.log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                        break
                      end
                    end
                  }
                  ptm_write_thread = Thread.start {
                    loop do
                      begin
                        ptm.write context.io[0].readpartial(10240)
                      rescue EOFError => e
                        context.log_info { "IO is EOF in ptm_write_thread" }
                        break
                      rescue IOError => e
                        context.log_warn { "IO Error in ptm_write_thread" }
                        break
                      rescue Errno::EIO => e
                        context.log_info { "EIO Error in ptm_read_thread" }
                        break
                      rescue => e
                        context.log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                        break
                      end
                    end
                  }
                  chain.call_next
                ensure
                  context.log_info { "closing pty-req request handler chain_proc" }
                  context.vars[:ptm].close rescue nil
                  context.vars[:pts].close rescue nil
                  ptm_read_thread.join
                  ptm_write_thread.exit
                  ptm_write_thread.join
                  context.log_info { "pty-req request handler chain_proc closed" }
                end
              }
            rescue => e
              ptm.close rescue nil
              pts.close rescue nil
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
