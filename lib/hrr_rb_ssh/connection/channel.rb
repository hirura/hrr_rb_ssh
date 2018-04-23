# coding: utf-8
# vim: et ts=2 sw=2

require 'socket'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/channel/channel_type'

module HrrRbSsh
  class Connection
    class Channel
      INITIAL_WINDOW_SIZE = 100000
      MAXIMUM_PACKET_SIZE = 100000

      attr_reader \
        :channel_type,
        :local_channel,
        :remote_channel,
        :local_window_size,
        :local_maximum_packet_size,
        :remote_window_size,
        :remote_maximum_packet_size,
        :receive_message_queue,
        :request_handler_io

      def initialize connection, message
        @logger = HrrRbSsh::Logger.new self.class.name

        @connection = connection

        @channel_type = message['channel type']
        @local_channel  = message['sender channel']
        @remote_channel = message['sender channel']
        @local_window_size          = INITIAL_WINDOW_SIZE
        @local_maximum_packet_size  = MAXIMUM_PACKET_SIZE
        @remote_window_size         = message['initial window size']
        @remote_maximum_packet_size = message['maximum packet size']

        @channel_type_instance = ChannelType[@channel_type].new connection, self, message

        @receive_message_queue = Queue.new
        @receive_data_queue = Queue.new

        @channel_io, @request_handler_io = UNIXSocket.pair

        @closed = nil
      end

      def start
        @channel_loop_thread = channel_loop_thread
        @sender_thread       = sender_thread
        @receiver_thread     = receiver_thread
        @channel_type_instance.start
        @closed = false
      end

      def close from=:outside, exitstatus=0
        return if @closed
        @logger.info("close channel")
        @closed = true
        unless from == :channel_type_instance
          @channel_type_instance.close
        end
        @receive_message_queue.close
        @receive_data_queue.close
        begin
          @request_handler_io.close
        rescue IOError # for compatibility for Ruby version < 2.3
          Thread.pass
        end
        begin
          @channel_io.close
        rescue IOError # for compatibility for Ruby version < 2.3
          Thread.pass
        end
        begin
          if from == :channel_type_instance
            send_channel_eof
            case exitstatus
            when Integer
              send_channel_request_exit_status exitstatus
            else
              @logger.warn("skip sending exit-status because exitstatus is not an instance of Integer")
            end
          end
          send_channel_close
        rescue HrrRbSsh::ClosedConnectionError => e
          Thread.pass
        rescue => e
          @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
        end
        @logger.info("channel closed")
      end

      def closed?
        @closed
      end

      def channel_loop_thread
        Thread.start do
          @logger.info("start channel loop thread")
          loop do
            begin
              message = @receive_message_queue.deq
              if message.nil? && @receive_message_queue.closed?
                @receive_data_queue.close
                @logger.info("closing channel loop thread")
                break
              end
              case message['message number']
              when HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE
                @logger.info("received channel request: #{message['request type']}")
                @channel_type_instance.request message
                if message['want reply']
                  send_channel_success
                end
              when HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE
                @logger.info("received channel data")
                local_channel = message['recipient channel']
                @receive_data_queue.enq message['data']
              when HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE
                @logger.debug("received channel window adjust")
                @remote_window_size = [@remote_window_size + message['bytes to add'], 0xffff_ffff].min
              else
                @logger.warn("received unsupported message: #{message.inspect}")
              end
            rescue => e
              @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
              close from=:channel_loop_thread
              break
            end
          end
          @logger.info("channel loop thread closed")
        end
      end

      def sender_thread
        Thread.start {
          @logger.info("start sender thread")
          loop do
            if @channel_io.closed?
              @logger.info("closing sender thread")
              break
            end
            begin
              data = @channel_io.readpartial(1024)
              sendable_size = [data.size, @remote_window_size].min
              sending_data = data[0, sendable_size]
              send_channel_data sending_data if sendable_size > 0
              @remote_window_size -= sendable_size
            rescue EOFError => e
              begin
                @channel_io.close
              rescue IOError # for compatibility for Ruby version < 2.3
                Thread.pass
              end
            rescue IOError => e
              @logger.warn("channel IO is closed")
              close
            rescue => e
              @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
              close
            end
          end
          @logger.info("sender thread closed")
        }
      end

      def receiver_thread
        Thread.start {
          @logger.info("start receiver thread")
          loop do
            begin
              data = @receive_data_queue.deq
              if data.nil? && @receive_data_queue.closed?
                @logger.info("closing receiver thread")
                @logger.info("closing channel IO write")
                @channel_io.close_write
                @logger.info("channel IO write closed")
                break
              end
              @channel_io.write data
              @local_window_size -= data.size
              if @local_window_size < INITIAL_WINDOW_SIZE/2
                @logger.info("send channel window adjust")
                send_channel_window_adjust
                @local_window_size += INITIAL_WINDOW_SIZE
              end
            rescue IOError => e
              @logger.warn("channel IO is closed")
              close
              break
            rescue => e
              @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
              close
              break
            end
          end
          @logger.info("receiver thread closed")
        }
      end

      def send_channel_success
        message = {
          'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS::VALUE,
          'recipient channel' => @remote_channel,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS.encode message
        @connection.send payload
      end

      def send_channel_window_adjust
        message = {
          'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE,
          'recipient channel' => @remote_channel,
          'bytes to add'      => INITIAL_WINDOW_SIZE,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.encode message
        @connection.send payload
      end

      def send_channel_data data
        message = {
          'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          'recipient channel' => @remote_channel,
          'data'              => data,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.encode message
        @connection.send payload
      end

      def send_channel_request_exit_status exitstatus
        message = {
          'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          'recipient channel' => @remote_channel,
          'request type'      => 'exit-status',
          'want reply'        => false,
          'exit status'       => exitstatus,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST.encode message
        @connection.send payload
      end

      def send_channel_eof
        message = {
          'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF::VALUE,
          'recipient channel' => @remote_channel,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF.encode message
        @connection.send payload
      end

      def send_channel_close
        message = {
          'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::VALUE,
          'recipient channel' => @remote_channel,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE.encode message
        @connection.send payload
      end
    end
  end
end
