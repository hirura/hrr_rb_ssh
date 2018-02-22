# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class Sender
      def initialize transport
        @transport = transport

        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def packetize payload
        packet_length_field_length  = 4
        padding_length_field_length = 1
        minimum_padding_length      = 4
        minimum_block_size          = 8

        deflated_payload = @transport.outgoing_compression_algorithm.deflate payload

        block_size       = [@transport.outgoing_encryption_algorithm.block_size, minimum_block_size].max
        tmp_total_length = packet_length_field_length + padding_length_field_length + deflated_payload.length + minimum_padding_length
        total_length     = tmp_total_length + (block_size - (tmp_total_length % block_size))
        packet_length    = total_length - packet_length_field_length
        padding_length   = packet_length - padding_length_field_length - deflated_payload.length
        padding          = OpenSSL::Random.random_bytes( padding_length )
        packet           = [packet_length, padding_length].pack("NC") + deflated_payload + padding

        encrypted_packet = @transport.outgoing_encryption_algorithm.encrypt( packet )
        mac              = @transport.outgoing_mac_algorithm.compute @transport.outgoing_sequence_number.sequence_number, packet

        encrypted_packet + mac
      end

      def send payload
        packet = packetize payload
        @transport.io.write packet
        @transport.outgoing_sequence_number.increment
      end
    end
  end
end
