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
        if (initial_encrypted_packet == nil) || (initial_encrypted_packet.length != block_size)
          @logger.warn("IO is EOF")
          raise EOFError
        end
        initial_unencrypted_packet = transport.incoming_encryption_algorithm.decrypt initial_encrypted_packet
        packet_length              = initial_unencrypted_packet[0,4].unpack("N")[0]
        last_packet_length         = packet_length_field_length + packet_length - block_size
        last_encrypted_packet      = transport.io.read last_packet_length
        if (last_encrypted_packet == nil) || (last_encrypted_packet.length != last_packet_length)
          @logger.warn("IO is EOF")
          raise EOFError
        end
        last_unencrypted_packet    = transport.incoming_encryption_algorithm.decrypt last_encrypted_packet
        encrypted_packet           = initial_encrypted_packet + last_encrypted_packet
        unencrypted_packet         = initial_unencrypted_packet + last_unencrypted_packet

        unencrypted_packet
      end

      def receive_mac transport
        mac_length = transport.incoming_mac_algorithm.digest_length
        mac = transport.io.read mac_length
        if (mac == nil) || (mac.length != mac_length)
          @logger.warn("IO is EOF")
          raise EOFError
        end
        mac
      end

      def receive transport
        unencrypted_packet = receive_packet transport
        payload            = depacketize transport, unencrypted_packet
        mac                = receive_mac transport

        raise if mac != transport.incoming_mac_algorithm.compute( transport.incoming_sequence_number.sequence_number, unencrypted_packet )

        transport.incoming_sequence_number.increment

        payload
      end
    end
  end
end
