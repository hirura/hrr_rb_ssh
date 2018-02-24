# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/packet'

module HrrRbSsh
  class Transport
    class Receiver
      def initialize
        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def receive_packet transport
        packet_length_field_length  = 4
        minimum_block_size          = 8

        block_size                 = [transport.incoming_encryption_algorithm.block_size, minimum_block_size].max
        initial_encrypted_packet   = transport.io.read block_size
        initial_unenceypted_packet = transport.incoming_encryption_algorithm.decrypt initial_encrypted_packet
        packet_length              = initial_unenceypted_packet[0,4].unpack("N")[0]
        last_encrypted_packet      = transport.io.read (packet_length_field_length + packet_length - block_size)
        encrypted_packet           = initial_encrypted_packet + last_encrypted_packet

        encrypted_packet
      end

      def receive_mac transport
        transport.io.read transport.incoming_mac_algorithm.length
      end

      def receive transport
        encrypted_packet = receive_packet transport
        packet = Packet.new_from_encrypted_packet transport, encrypted_packet
        mac = receive_mac transport
        raise unless transport.incoming_mac_algorithm.valid? transport, packet.unencrypted, mac
        transport.incoming_sequence_number.increment
        packet
      end
    end
  end
end
