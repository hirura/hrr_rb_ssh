# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/error/closed_connection'
require 'hrr_rb_ssh/connection/global_request_handler'
require 'hrr_rb_ssh/connection/channel'

module HrrRbSsh
  class Connection
    attr_reader \
      :username,
      :variables,
      :options,
      :mode

    def initialize authentication, mode, options={}
      @logger = Logger.new self.class.name

      @authentication = authentication
      @mode = mode
      @options = options

      @global_request_handler = GlobalRequestHandler.new self
      @channels = Hash.new
      @username = nil
      @variables = nil
      @closed = nil
    end

    def send payload
      raise Error::ClosedConnection if @closed
      begin
        @authentication.send payload
      rescue Error::ClosedAuthentication
        raise Error::ClosedConnection
      end
    end

    def assign_channel
      i = 0
      res = nil
      while true
        break unless @channels.keys.include?(i)
        i += 1
      end
      i
    end

    def start foreground: true
      @logger.info { "start connection" }
      @authentication.start
      @closed = false
      @connection_loop_thread = connection_loop_thread
      if foreground
        @connection_loop_thread.join
      end
    end

    def loop
      @connection_loop_thread.join
    end

    def close
      @logger.info { "closing connection" }
      @closed = true
      @authentication.close
      @channels.values.each do |channel|
        begin
          channel.close
        rescue => e
          @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        end
      end
      @channels.clear
      @global_request_handler.close
      @connection_loop_thread.join unless @connection_loop_thread == Thread.current
      @logger.info { "connection closed" }
    end

    def closed?
      @closed
    end

    def connection_loop_thread
      @logger.info { "start connection loop" }
      Thread.new do
        begin
          while true
            begin
              payload = @authentication.receive
            rescue Error::ClosedAuthentication => e
              @logger.info { "authentication closed" }
              break
            end
            @username ||= @authentication.username
            @variables ||= @authentication.variables
            case payload[0,1].unpack("C")[0]
            when Message::SSH_MSG_GLOBAL_REQUEST::VALUE
              global_request payload
            when Message::SSH_MSG_CHANNEL_OPEN::VALUE
              channel_open payload
            when Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE
              channel_open_confirmation payload
            when Message::SSH_MSG_CHANNEL_REQUEST::VALUE
              channel_request payload
            when Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE
              channel_window_adjust payload
            when Message::SSH_MSG_CHANNEL_DATA::VALUE
              channel_data payload
            when Message::SSH_MSG_CHANNEL_EXTENDED_DATA::VALUE
              channel_extended_data payload
            when Message::SSH_MSG_CHANNEL_EOF::VALUE
              channel_eof payload
            when Message::SSH_MSG_CHANNEL_CLOSE::VALUE
              channel_close payload
            else
              @logger.warn { "received unsupported message: id: #{payload[0,1].unpack("C")[0]}" }
            end
          end
        rescue => e
          @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        ensure
          @logger.info { "closing connection loop" }
          close
          @logger.info { "connection loop closed" }
        end
      end
    end

    def global_request payload
      @logger.info { 'received ' + Message::SSH_MSG_GLOBAL_REQUEST::ID }
      message = Message::SSH_MSG_GLOBAL_REQUEST.decode payload
      begin
        @global_request_handler.request message
      rescue
        if message[:'want reply']
          send_request_failure
        end
      else
        if message[:'want reply']
          send_request_success
        end
      end
    end

    def channel_open_start address, port, socket
      @logger.info { 'channel open start' }
      channel = Channel.new self, {:'channel type' => "forwarded-tcpip"}, socket
      @channels[channel.local_channel] = channel
      @logger.info { 'channel opened' }
      message = {
        :'message number'             => Message::SSH_MSG_CHANNEL_OPEN::VALUE,
        :'channel type'               => "forwarded-tcpip",
        :'sender channel'             => channel.local_channel,
        :'initial window size'        => channel.local_window_size,
        :'maximum packet size'        => channel.local_maximum_packet_size,
        :'address that was connected' => address,
        :'port that was connected'    => port,
        :'originator IP address'      => socket.remote_address.ip_address,
        :'originator port'            => socket.remote_address.ip_port,
      }
      send_channel_open message
    end

    def channel_open payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_OPEN::ID }
      message = Message::SSH_MSG_CHANNEL_OPEN.decode payload
      begin
        channel = Channel.new self, message
        @channels[channel.local_channel] = channel
        channel.start
        send_channel_open_confirmation channel
      rescue => e
        @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        recipient_channel = message[:'sender channel']
        send_channel_open_failure recipient_channel, Message::SSH_MSG_CHANNEL_OPEN_FAILURE::ReasonCode::SSH_OPEN_CONNECT_FAILED, e.message
      end
    end

    def request_channel_open channel_type, channel_specific_message={}, wait_response=true
      @logger.info { 'request channel open' }
      case channel_type
      when "session"
        channel = Channel.new self, {:'channel type' => channel_type}
        @channels[channel.local_channel] = channel
      end
      message = {
        :'message number'             => Message::SSH_MSG_CHANNEL_OPEN::VALUE,
        :'channel type'               => channel_type,
        :'sender channel'             => channel.local_channel,
        :'initial window size'        => channel.local_window_size,
        :'maximum packet size'        => channel.local_maximum_packet_size,
      }
      send_channel_open message.merge(channel_specific_message)
      @logger.info { 'sent channel open' }
      if wait_response
        @logger.info { 'wait response' }
        channel.wait_until_started
      end
      unless channel.closed?
        @logger.info { 'channel opened' }
        channel
      else
        raise "Faild opening channel"
      end
    end

    def channel_open_confirmation payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::ID }
      message = Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.decode payload
      channel = @channels[message[:'recipient channel']]
      channel.set_remote_parameters message
      channel.start
    end

    def channel_request payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_REQUEST::ID }
      message = Message::SSH_MSG_CHANNEL_REQUEST.decode payload
      local_channel = message[:'recipient channel']
      @channels[local_channel].receive_message_queue.enq message
    end

    def channel_window_adjust payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::ID }
      message = Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.decode payload
      local_channel = message[:'recipient channel']
      @channels[local_channel].receive_message_queue.enq message
    end

    def channel_data payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_DATA::ID }
      message = Message::SSH_MSG_CHANNEL_DATA.decode payload
      local_channel = message[:'recipient channel']
      @channels[local_channel].receive_message_queue.enq message
    end

    def channel_extended_data payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_EXTENDED_DATA::ID }
      message = Message::SSH_MSG_CHANNEL_EXTENDED_DATA.decode payload
      local_channel = message[:'recipient channel']
      @channels[local_channel].receive_message_queue.enq message
    end

    def channel_eof payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_EOF::ID }
      message = Message::SSH_MSG_CHANNEL_EOF.decode payload
      local_channel = message[:'recipient channel']
      @channels[local_channel].receive_message_queue.enq message
    end

    def channel_close payload
      @logger.info { 'received ' + Message::SSH_MSG_CHANNEL_CLOSE::ID }
      message = Message::SSH_MSG_CHANNEL_CLOSE.decode payload
      local_channel = message[:'recipient channel']
      channel = @channels[local_channel]
      channel.close
      @logger.info { "wait until threads closed in channel" }
      channel.wait_until_closed
      @logger.info { "channel closed" }
      @logger.info { "deleting channel" }
      @channels.delete local_channel
      @logger.info { "channel deleted" }
    end

    def send_request_success
      message = {
        :'message number' => Message::SSH_MSG_REQUEST_SUCCESS::VALUE,
      }
      payload = Message::SSH_MSG_REQUEST_SUCCESS.encode message
      @authentication.send payload
    end

    def send_request_failure
      message = {
        :'message number' => Message::SSH_MSG_REQUEST_FAILURE::VALUE,
      }
      payload = Message::SSH_MSG_REQUEST_FAILURE.encode message
      @authentication.send payload
    end

    def send_channel_open message
      payload = Message::SSH_MSG_CHANNEL_OPEN.encode message
      @authentication.send payload
    end

    def send_channel_open_confirmation channel
      message = {
        :'message number'      => Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE,
        :'channel type'        => channel.channel_type,
        :'recipient channel'   => channel.remote_channel,
        :'sender channel'      => channel.local_channel,
        :'initial window size' => channel.local_window_size,
        :'maximum packet size' => channel.local_maximum_packet_size,
      }
      payload = Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.encode message
      @authentication.send payload
    end

    def send_channel_open_failure recipient_channel, reason_code, description
      message = {
        :'message number'      => Message::SSH_MSG_CHANNEL_OPEN_FAILURE::VALUE,
        :'recipient channel'   => recipient_channel,
        :'reason code'         => reason_code,
        :'description'         => description,
        :'language tag'        => "",
      }
      payload = Message::SSH_MSG_CHANNEL_OPEN_FAILURE.encode message
      @authentication.send payload
    end
  end
end
