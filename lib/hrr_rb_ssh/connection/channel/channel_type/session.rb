# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session < ChannelType
          include Loggable

          NAME = 'session'

          def initialize connection, channel, message, socket=nil, logger: nil
            self.logger = logger
            @connection = connection
            @channel = channel
            @proc_chain = ProcChain.new
          end

          def start
            case @connection.mode
            when Mode::SERVER
              @proc_chain_thread = proc_chain_thread
            end
          end

          def close
            if @proc_chain_thread
              @proc_chain_thread.exit
            end
          end

          def request message
            request_type = message[:'request type']
            RequestType[request_type].run @proc_chain, @connection.username, @channel.io, @connection.variables, message, @connection.options, self, logger: logger
          end

          def proc_chain_thread
            Thread.start {
              log_info { "start proc chain thread" }
              begin
                exitstatus = @proc_chain.call_next
              rescue => e
                log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                exitstatus = 1
              ensure
                log_info { "closing proc chain thread" }
                log_info { "closing channel IOs" }
                @channel.io.each{ |io| io.close rescue nil }
                log_info { "channel IOs closed" }
                log_info { "wait for sending output" }
                @channel.wait_until_senders_closed
                log_info { "sending output finished" }
                @channel.close from=:channel_type_instance, exitstatus=exitstatus
                log_info { "proc chain thread closed" }
              end
            }
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session/proc_chain'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type'
