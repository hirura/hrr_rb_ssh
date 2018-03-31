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
        :receive_queue

      def initialize connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
        @logger = HrrRbSsh::Logger.new self.class.name

        @connection = connection
        @channel_type = channel_type
        @local_channel  = local_channel
        @remote_channel = remote_channel
        @initial_window_size = initial_window_size
        @maximum_packet_size = maximum_packet_size

        @receive_queue = Queue.new
        @receive_data  = Queue.new

        @proc_chain = ProcChain.new
        @channel_io, @request_handler_io = UNIXSocket.pair
      end

      def start
        channel_loop_thread
        io_threads
        proc_chain_thread
      end

      def channel_loop_thread
        Thread.start do
          variables = {}
          while message = @receive_queue.deq
            @logger.debug("received message: " + message.inspect)
            if message.has_key?(HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::ID)
              @logger.debug("received channel request: #{message['channel type']}")
              local_channel  = message['recipient channel']
              remote_channel = message['sender channel']
              request message, variables
              if message['want reply']
                send_channel_success
              end
            elsif message.has_key?(HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::ID)
              @logger.debug("received channel data")
              local_channel = message['recipient channel']
              @receive_data.enq message['data']
            end
          end
        end
      end

      def io_threads
        threads = Array.new
        threads.push Thread.start {
          while data = @receive_data.deq
            @channel_io.write data
          end
        }
        threads.push Thread.start {
          until (data = @channel_io.recv(1024)).empty?
            send_channel_data data
          end
        }
        threads
      end

      def proc_chain_thread
        Thread.start {
          @proc_chain.call_next
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
    end
  end
end
