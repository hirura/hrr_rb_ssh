# coding: utf-8
# vim: et ts=2 sw=2

require 'socket'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/channel/proc_chain'
require 'hrr_rb_ssh/connection/channel/session'

module HrrRbSsh
  class Connection
    class Channel
      @@type_list ||= Hash.new

      def self.[] key
        @@type_list[key]
      end

      def self.type_list
        @@type_list.keys
      end

      attr_reader \
        :receive_payload_queue

      def initialize connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
        @logger = HrrRbSsh::Logger.new self.class.name

        @connection = connection
        @channel_type = channel_type
        @local_channel  = local_channel
        @remote_channel = remote_channel
        @initial_window_size = initial_window_size
        @maximum_packet_size = maximum_packet_size

        @receive_payload_queue = Queue.new
        @receive_data_queue = Queue.new

        @proc_chain = ProcChain.new
        @channel_io, @request_handler_io = UNIXSocket.pair

        @closed = nil
      end

      def start
        @channel_loop_thread = channel_loop_thread
        @sender_thread       = sender_thread
        @receiver_thread     = receiver_thread
        @proc_chain_thread   = proc_chain_thread
        @closed = false
      end

      def close from=:outside, exitstatus=0
        return if @closed
        @logger.info("close channel")
        @closed = true
        unless from == :proc_chain_thread
          @proc_chain_thread.exit
        end
        @receive_payload_queue.close
        @receive_data_queue.close
        @request_handler_io.close
        @channel_io.close
        begin
          if from == :proc_chain_thread
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
          @logger.error(e.full_message)
        end
        @logger.info("channel closed")
      end

      def closed?
        @closed
      end

      def channel_loop_thread
        Thread.start do
          @logger.info("start channel loop thread")
          variables = {}
          loop do
            begin
              message = @receive_payload_queue.deq
              if message.nil? && @receive_payload_queue.closed?
                @logger.info("closing channel loop thread")
                break
              end
              if message.has_key?(HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::ID)
                @logger.info("received channel request: #{message['request type']}")
                request message, variables
                if message['want reply']
                  send_channel_success
                end
              elsif message.has_key?(HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::ID)
                @logger.info("received channel data")
                local_channel = message['recipient channel']
                @receive_data_queue.enq message['data']
              else
                @logger.warn("received unsupported message: #{message.inspect}")
              end
            rescue => e
              @logger.error(e.full_message)
              break
            end
          end
          close from=:channel_loop_thread
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
              send_channel_data data
            rescue EOFError => e
              @channel_io.close
            rescue IOError => e
              @logger.warn("channel IO is closed")
              close
            rescue => e
              @logger.error(e.full_message)
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
                break
              end
              @channel_io.write data
            rescue IOError => e
              @logger.warn("channel IO is closed")
              close
            rescue => e
              @logger.error(e.full_message)
              close
            end
          end
          @logger.info("receiver thread closed")
        }
      end

      def proc_chain_thread
        Thread.start {
          @logger.info("start proc chain thread")
          begin
            exitstatus = @proc_chain.call_next
          rescue => e
            @logger.error(e.full_message)
            exitstatus = 1
          ensure
            @logger.info("closing proc chain thread")
            close from=:proc_chain_thread, exitstatus=exitstatus
            @logger.info("proc chain thread closed")
          end
        }
      end

      def request message, variables
        request_type = message['request type']
        @@type_list[@channel_type][request_type].run @proc_chain, @connection.username, @request_handler_io, variables, message, @connection.options
      end

      def send_channel_success
        message = {
          'SSH_MSG_CHANNEL_SUCCESS' => HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS::VALUE,
          'recipient channel'       => @remote_channel,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS.encode message
        @connection.send payload
      end

      def send_channel_data data
        message = {
          'SSH_MSG_CHANNEL_DATA' => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          'recipient channel'    => @remote_channel,
          'data'                 => data,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.encode message
        @connection.send payload
      end

      def send_channel_request_exit_status exitstatus
        message = {
          'SSH_MSG_CHANNEL_REQUEST' => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          'recipient channel'       => @remote_channel,
          'request type'            => 'exit-status',
          'want reply'              => false,
          'exit status'             => exitstatus,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST.encode message
        @connection.send payload
      end

      def send_channel_eof
        message = {
          'SSH_MSG_CHANNEL_EOF' => HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF::VALUE,
          'recipient channel'   => @remote_channel,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF.encode message
        @connection.send payload
      end

      def send_channel_close
        message = {
          'SSH_MSG_CHANNEL_CLOSE' => HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::VALUE,
          'recipient channel'     => @remote_channel,
        }
        payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE.encode message
        @connection.send payload
      end
    end
  end
end
