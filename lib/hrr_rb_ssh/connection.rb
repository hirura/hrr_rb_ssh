# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/channel'

module HrrRbSsh
  class Connection
    attr_reader \
      :options

    def initialize authentication, options={}
      @logger = HrrRbSsh::Logger.new self.class.name

      @authentication = authentication
      @options = options

      @channels = Hash.new
    end

    def start
      @authentication.start
      start_connection_loop
    end

    def start_connection_loop
      while payload = @authentication.receive
        case payload[0,1].unpack("C")[0]
        when HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE
          channel_open payload
        end
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
      send_channel_open_confirmation channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
    end

    def send_channel_open_confirmation channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
      message = {
        'SSH_MSG_CHANNEL_OPEN_CONFIRMATION' => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE,
        'channel type'                      => channel_type,
        'recipient channel'                 => remote_channel,
        'sender channel'                    => local_channel,
        'initial window size'               => initial_window_size,
        'maximum packet size'               => maximum_packet_size,
      }
      payload = HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.encode message
      @authentication.send payload
    end
  end
end
