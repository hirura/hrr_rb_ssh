# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      name_list = [
        'none'
      ]

      class None
        DIGEST_LENGTH = 0
        KEY_LENGTH    = 0

        def initialize incoming_key=nil, outgoing_key=nil
          @logger = HrrRbSsh::Logger.new self.class.name
        end

        def compute sequence_number, unencrypted_packet, key=nil
          String.new
        end

        def valid? sequence_number, unencrypted_packet, mac
          mac == compute( sequence_number, unencrypted_packet )
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
        @@list[name] = None
      end
    end
  end
end
