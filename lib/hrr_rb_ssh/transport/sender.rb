# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class Sender
      def initialize
        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def send_packet transport, packet
        encrypted_packet = packet.encrypted
        transport.io.write encrypted_packet
      end

      def send_mac transport, packet
        mac = transport.outgoing_mac_algorithm.compute transport.outgoing_sequence_number.sequence_number, packet.unencrypted
        transport.io.write mac
      end

      def send transport, packet
        send_packet transport, packet
        send_mac transport, packet
        transport.outgoing_sequence_number.increment
      end
    end
  end
end
