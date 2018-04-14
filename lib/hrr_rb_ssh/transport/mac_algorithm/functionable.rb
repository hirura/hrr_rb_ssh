# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      module Functionable
        def initialize key
          @logger = HrrRbSsh::Logger.new(self.class.name)
          @key = key
        end

        def digest_length
          self.class::DIGEST_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end

        def compute sequence_number, unencrypted_packet
          data = HrrRbSsh::DataType::Uint32.encode(sequence_number) + unencrypted_packet
          digest = OpenSSL::HMAC.digest self.class::DIGEST, @key, data
          digest[0, digest_length]
        end
      end
    end
  end
end
