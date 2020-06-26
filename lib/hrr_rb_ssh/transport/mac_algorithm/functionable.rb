module HrrRbSsh
  class Transport
    class MacAlgorithm
      module Functionable
        include Loggable

        def initialize key, logger: nil
          self.logger = logger
          @key = key
        end

        def digest_length
          self.class::DIGEST_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end

        def compute sequence_number, unencrypted_packet
          data = DataTypes::Uint32.encode(sequence_number) + unencrypted_packet
          digest = OpenSSL::HMAC.digest self.class::DIGEST, @key, data
          digest[0, digest_length]
        end
      end
    end
  end
end
