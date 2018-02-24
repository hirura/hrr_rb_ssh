# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class Packet
      attr_reader \
        :packet_length,
        :padding_length,
        :payload,
        :padding

      class << self
        def new_from_payload transport, payload
          packet = self.new
          packet.packetize transport, payload
          packet
        end

        def new_from_encrypted_packet transport, encrypted_packet
          packet = self.new
          packet.depacketize transport, encrypted_packet
          packet
        end
      end

      def initialize
        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def encrypted
        @encrypted_packet
      end

      def unencrypted
        @unencrypted_packet
      end

      def packetize transport, payload
        packet_length_field_length  = 4
        padding_length_field_length = 1
        minimum_padding_length      = 4
        minimum_block_size          = 8

        block_size         = [transport.outgoing_encryption_algorithm.block_size, minimum_block_size].max
        deflated_payload   = transport.outgoing_compression_algorithm.deflate payload
        tmp_total_length   = packet_length_field_length + padding_length_field_length + deflated_payload.length + minimum_padding_length
        total_length       = tmp_total_length + (block_size - (tmp_total_length % block_size))
        packet_length      = total_length - packet_length_field_length
        padding_length     = packet_length - padding_length_field_length - deflated_payload.length
        padding            = OpenSSL::Random.random_bytes( padding_length )
        unencrypted_packet = [packet_length, padding_length].pack("NC") + deflated_payload + padding
        encrypted_packet   = transport.outgoing_encryption_algorithm.encrypt( unencrypted_packet )

        @encrypted_packet   = encrypted_packet
        @unencrypted_packet = unencrypted_packet
        @packet_length      = packet_length
        @padding_length     = padding_length
        @payload            = payload
        @padding            = padding

        encrypted_packet
      end

      def depacketize transport, encrypted_packet
        packet_length_field_length  = 4
        padding_length_field_length = 1

        unencrypted_packet      = transport.incoming_encryption_algorithm.decrypt( encrypted_packet )
        packet_length           = unencrypted_packet[0,4].unpack("N")[0]
        padding_length          = unencrypted_packet[4,1].unpack("C")[0]
        deflated_payload_length = packet_length - padding_length_field_length - padding_length
        deflated_payload        = unencrypted_packet[packet_length_field_length + padding_length_field_length, deflated_payload_length]
        payload                 = transport.incoming_compression_algorithm.inflate deflated_payload
        padding                 = unencrypted_packet[packet_length_field_length + padding_length_field_length + deflated_payload_length, padding_length]

        @encrypted_packet   = encrypted_packet
        @unencrypted_packet = unencrypted_packet
        @packet_length      = packet_length
        @padding_length     = padding_length
        @payload            = payload
        @padding            = padding

        payload
      end
    end
  end
end
