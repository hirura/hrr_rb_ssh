# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Transport
    class Sender
      include Loggable

      def initialize logger: nil
        self.logger = logger
      end

      def packetize transport, payload
        packet_length_field_length  = 4
        padding_length_field_length = 1
        minimum_padding_length      = 4
        minimum_block_size          = 8

        block_size       = [transport.outgoing_encryption_algorithm.block_size, minimum_block_size].max
        deflated_payload = transport.outgoing_compression_algorithm.deflate payload
        tmp_total_length = packet_length_field_length + padding_length_field_length + deflated_payload.length + minimum_padding_length
        total_length     = tmp_total_length + (block_size - (tmp_total_length % block_size))
        packet_length    = total_length - packet_length_field_length
        padding_length   = packet_length - padding_length_field_length - deflated_payload.length
        padding          = OpenSSL::Random.random_bytes( padding_length )
        packet           = [packet_length, padding_length].pack("NC") + deflated_payload + padding

        packet
      end

      def encrypt transport, packet
        encrypted_packet = transport.outgoing_encryption_algorithm.encrypt packet

        encrypted_packet
      end

      def send_packet transport, packet
        encrypted_packet = encrypt transport, packet
        transport.io.write encrypted_packet
      end

      def send_mac transport, packet
        mac = transport.outgoing_mac_algorithm.compute transport.outgoing_sequence_number.sequence_number, packet
        transport.io.write mac
      end

      def send transport, payload
        packet = packetize transport, payload

        send_packet transport, packet
        send_mac    transport, packet

        transport.outgoing_sequence_number.increment
      end
    end
  end
end
