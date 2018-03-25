# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
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

      def initialize connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size
        @logger = HrrRbSsh::Logger.new self.class.name

        @connection = connection
        @channel_type = channel_type
        @local_channel  = local_channel
        @remote_channel = remote_channel
        @initial_window_size = initial_window_size
        @maximum_packet_size = maximum_packet_size
      end
    end
  end
end
