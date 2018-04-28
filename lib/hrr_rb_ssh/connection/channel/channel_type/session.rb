# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session < ChannelType
          NAME = 'session'

          def initialize connection, channel, message
            @logger = HrrRbSsh::Logger.new self.class.name
            @connection = connection
            @channel = channel
            @variables = {}
            @proc_chain = ProcChain.new
          end

          def start
            @proc_chain_thread = proc_chain_thread
          end

          def close
            if @proc_chain_thread
              @proc_chain_thread.exit
            end
          end

          def request message
            request_type = message[:'request type']
            RequestType[request_type].run @proc_chain, @connection.username, @channel.io, @variables, message, @connection.options
          end

          def proc_chain_thread
            Thread.start {
              @logger.info("start proc chain thread")
              begin
                exitstatus = @proc_chain.call_next
              rescue => e
                @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
                exitstatus = 1
              ensure
                @logger.info("closing proc chain thread")
                @logger.info("wait for sending output")
                @channel.wait_until_senders_closed
                @logger.info("sending output finished")
                @channel.close from=:channel_type_instance, exitstatus=exitstatus
                @logger.info("proc chain thread closed")
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
