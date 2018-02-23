# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class Receiver
      def initialize transport
        @transport = transport

        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def depacketize
        packet_length_field_length  = 4
        padding_length_field_length = 1
        minimum_block_size          = 8

        block_size               = [@transport.incoming_encryption_algorithm.block_size, minimum_block_size].max

        initial_encrypted_packet = @transport.io.read block_size
        initial_packet           = @transport.incoming_encryption_algorithm.decrypt initial_encrypted_packet

        packet_length            = initial_packet[0,4].unpack("N")[0]

        last_encrypted_packet    = @transport.io.read (packet_length_field_length + packet_length - block_size)
        last_packet              = @transport.incoming_encryption_algorithm.decrypt last_encrypted_packet

        mac                      = @transport.io.read @transport.incoming_mac_algorithm.length

        packet                   = initial_packet + last_packet

        padding_length           = packet[4,1].unpack("C")[0]
        inflated_payload_length  = packet_length - padding_length_field_length - padding_length

        inflated_payload         = packet[packet_length_field_length + padding_length_field_length, inflated_payload_length]
        payload                  = @transport.incoming_compression_algorithm.deflate inflated_payload

        raise unless @transport.incoming_mac_algorithm.valid? @transport, packet, mac

        payload
      end

      def receive
        payload = depacketize
        @transport.incoming_sequence_number.increment
        payload
      end
    end
  end
end
