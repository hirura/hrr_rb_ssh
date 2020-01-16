# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Transport
    class Receiver
      include Loggable

      def initialize logger: nil
        self.logger = logger
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
        packet_length_field_length = 4
        minimum_block_size         = 8

        encrypted_packet   = Array.new
        unencrypted_packet = Array.new

        block_size = [transport.incoming_encryption_algorithm.block_size, minimum_block_size].max
        encrypted_packet.push transport.io.read(block_size)
        if (encrypted_packet.last == nil) || (encrypted_packet.last.length != block_size)
          log_info { "IO is EOF" }
          raise EOFError
        end
        unencrypted_packet.push transport.incoming_encryption_algorithm.decrypt(encrypted_packet.last)

        packet_length           = unencrypted_packet.last[0,4].unpack("N")[0]
        following_packet_length = packet_length_field_length + packet_length - block_size
        encrypted_packet.push transport.io.read(following_packet_length)
        if (encrypted_packet.last == nil) || (encrypted_packet.last.length != following_packet_length)
          log_info { "IO is EOF" }
          raise EOFError
        end
        unencrypted_packet.push transport.incoming_encryption_algorithm.decrypt(encrypted_packet.last)

        unencrypted_packet.join
      end

      def receive_mac transport
        mac_length = transport.incoming_mac_algorithm.digest_length
        mac = transport.io.read mac_length
        if (mac == nil) || (mac.length != mac_length)
          log_info { "IO is EOF" }
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
