# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/closed_connection_error'
require 'hrr_rb_ssh/connection/channel'

module HrrRbSsh
  class Connection
    attr_reader \
      :username,
      :options

    def initialize authentication, options={}
      @logger = HrrRbSsh::Logger.new self.class.name

      @authentication = authentication
      @options = options

      @channels = Hash.new
      @username = nil
      @closed = nil
    end

    def send payload
      raise ClosedConnectionError if @closed
      begin
        @authentication.send payload
      rescue ClosedAuthenticationError
        raise ClosedConnectionError
      end
    end

    def start
      @authentication.start
      @closed = false
      connection_loop
    end

    def close
      @closed = true
      @channels.values.each do |channel|
        begin
          channel.close
        rescue => e
          @logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
        end
      end
      @channels.clear
    end

    def closed?
      @closed
    end

    def connection_loop
      @logger.info("start connection")
      loop do
        begin
          payload = @authentication.receive
        rescue HrrRbSsh::ClosedAuthenticationError => e
          @logger.info("closing connection loop")
          break
        end
        @username ||= @authentication.username
        case payload[0,1].unpack("C")[0]
        when HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST::VALUE
          global_request payload
        when HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE
          channel_open payload
        when HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE
          channel_request payload
        when HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE
          channel_window_adjust payload
        when HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE
          channel_data payload
        when HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::VALUE
          channel_close payload
        else
          @logger.warn("received unsupported message: id: #{payload[0,1].unpack("C")[0]}")
        end
      end
      @logger.info("closing connection")
      close
      @logger.info("connection closed")
    end

    def global_request payload
      @logger.info('received ' + HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST::ID)
      message = HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST.decode payload
      if message['want reply']
        # returns always failure because global request is not supported so far
        send_request_failure
      end
    end

    def channel_open payload
      @logger.info('received ' + HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::ID)
      message = HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN.decode payload
      channel_type = message['channel type']
      local_channel  = message['sender channel']
      remote_channel = message['sender channel']
      initial_window_size = message['initial window size']
      maximum_packet_size = message['maximum packet size']
      channel = Channel.new self, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
      @channels[local_channel] = channel
      channel.start
      send_channel_open_confirmation channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
    end

    def channel_request payload
      @logger.info('received ' + HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::ID)
      message = HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST.decode payload
      local_channel = message['recipient channel']
      @channels[local_channel].receive_payload_queue.enq message
    end

    def channel_window_adjust payload
      @logger.info('received ' + HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::ID)
      message = HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.decode payload
      local_channel = message['recipient channel']
      @channels[local_channel].receive_payload_queue.enq message
    end

    def channel_data payload
      @logger.info('received ' + HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::ID)
      message = HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.decode payload
      local_channel = message['recipient channel']
      @channels[local_channel].receive_payload_queue.enq message
    end

    def channel_close payload
      @logger.info('received ' + HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::ID)
      message = HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE.decode payload
      local_channel = message['recipient channel']
      channel = @channels[local_channel]
      channel.close
      @channels.delete local_channel
    end

    def send_request_success
      message = {
        'message number' => HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS::VALUE,
      }
      payload = HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS.encode message
      @authentication.send payload
    end

    def send_request_failure
      message = {
        'message number' => HrrRbSsh::Message::SSH_MSG_REQUEST_FAILURE::VALUE,
      }
      payload = HrrRbSsh::Message::SSH_MSG_REQUEST_FAILURE.encode message
      @authentication.send payload
    end

    def send_channel_open_confirmation channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
      message = {
        'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE,
        'channel type'        => channel_type,
        'recipient channel'   => remote_channel,
        'sender channel'      => local_channel,
        'initial window size' => initial_window_size,
        'maximum packet size' => maximum_packet_size,
      }
      payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.encode message
      @authentication.send payload
    end
  end
end
