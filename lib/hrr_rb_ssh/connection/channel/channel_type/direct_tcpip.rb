# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class DirectTcpip < ChannelType
          NAME = 'direct-tcpip'

          def initialize connection, channel, message
            @logger = HrrRbSsh::Logger.new self.class.name
            @connection = connection
            @channel = channel
            @host_to_connect       = message[:'host to connect']
            @port_to_connect       = message[:'port to connect']
            @originator_IP_address = message[:'originator IP address']
            @originator_port       = message[:'originator port']
          end

          def start
            @socket = TCPSocket.new @host_to_connect, @port_to_connect
            @sender_thread = sender_thread
            @receiver_thread = receiver_thread
          end

          def close
            begin
              if @sender_thread_finished && @receiver_thread_finished
                @logger.info("closing direct-tcpip")
                @socket.close
                @channel.close from=:channel_type_instance
                @logger.info("direct-tcpip closed")
              end
            rescue => e
              @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
            end
          end

          def sender_thread
            Thread.new(@socket){ |s|
              begin
                loop do
                  begin
                    @channel.io[1].write s.readpartial(10240)
                  rescue EOFError
                    @logger.info("socket is EOF")
                    @channel.io[1].close
                    break
                  rescue IOError
                    @logger.info("socket is closed")
                    @channel.io[1].close
                    break
                  rescue => e
                    @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
                    @channel.io[1].close
                    break
                  end
                end
                @logger.info("finishing sender thread")
                @sender_thread_finished = true
                close
              ensure
                @logger.info("sender thread finished")
              end
            }
          end

          def receiver_thread
            Thread.new(@socket){ |s|
              begin
                loop do
                  begin
                    s.write @channel.io[0].readpartial(10240)
                  rescue EOFError
                    @logger.info("io is EOF")
                    s.close_write
                    break
                  rescue IOError
                    @logger.info("socket is closed")
                    break
                  rescue => e
                    @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
                    s.close_write
                    break
                  end
                end
                @logger.info("finishing receiver thread")
                @receiver_thread_finished = true
                close
              ensure
                @logger.info("receiver thread finished")
              end
            }
          end
        end
      end
    end
  end
end
