# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
#require 'hrr_rb_ssh/transport/packet'

module HrrRbSsh
  class Transport
    class Receiver
      def initialize
        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def depacketize transport, packet
        packet_length_field_length  = 4
        padding_length_field_length = 1

        packet_length           = packet[0,4].unpack("N")[0]
        padding_length          = packet[4,1].unpack("C")[0]
        deflated_payload_length = packet_length - padding_length_field_length - padding_length
        deflated_payload        = packet[packet_length_field_length + padding_length_field_length, deflated_payload_length]
        payload                 = transport.incoming_compression_algorithm.inflate deflated_payload

        payload
      end

      def receive_packet transport
        packet_length_field_length  = 4
        minimum_block_size          = 8

        block_size                 = [transport.incoming_encryption_algorithm.block_size, minimum_block_size].max
        initial_encrypted_packet   = transport.io.read block_size
        initial_unencrypted_packet = transport.incoming_encryption_algorithm.decrypt initial_encrypted_packet
        packet_length              = initial_unencrypted_packet[0,4].unpack("N")[0]
        last_encrypted_packet      = transport.io.read (packet_length_field_length + packet_length - block_size)
        last_unencrypted_packet    = transport.incoming_encryption_algorithm.decrypt last_encrypted_packet
        encrypted_packet           = initial_encrypted_packet + last_encrypted_packet
        unencrypted_packet         = initial_unencrypted_packet + last_unencrypted_packet

        unencrypted_packet
      end

      def receive_mac transport
        transport.io.read transport.incoming_mac_algorithm.digest_length
      end

      def receive transport
        packet  = receive_packet transport
        payload = depacketize transport, packet
        mac     = receive_mac transport

        raise unless transport.incoming_mac_algorithm.valid? transport.incoming_sequence_number.sequence_number, packet, mac

        transport.incoming_sequence_number.increment

        payload
      end
    end
  end
end
