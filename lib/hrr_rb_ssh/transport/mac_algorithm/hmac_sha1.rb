# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      name_list = [
        'hmac-sha1'
      ]

      class HmacSha1
        DIGEST = 'sha1'

        DIGEST_LENGTH = 20
        KEY_LENGTH    = 20

        def initialize incoming_key, outgoing_key
          @logger = HrrRbSsh::Logger.new self.class.name

          @incoming_key = incoming_key
          @outgoing_key = outgoing_key
        end

        def compute sequence_number, unencrypted_packet, key=@outgoing_key
          data = HrrRbSsh::Transport::DataType::Uint32.encode(sequence_number) + unencrypted_packet
          OpenSSL::HMAC.digest DIGEST, key, data
        end

        def valid? sequence_number, unencrypted_packet, mac
          mac == compute( sequence_number, unencrypted_packet, @incoming_key )
        end

        def digest_length
          DIGEST_LENGTH
        end

        def key_length
          KEY_LENGTH
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = HmacSha1
      end
    end
  end
end
