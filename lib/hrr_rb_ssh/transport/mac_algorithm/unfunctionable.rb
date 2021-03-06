module HrrRbSsh
  class Transport
    class MacAlgorithm
      module Unfunctionable
        include Loggable

        def initialize key=nil, logger: nil
          self.logger = logger
        end

        def digest_length
          self.class::DIGEST_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end

        def compute sequence_number, unencrypted_packet
          String.new
        end
      end
    end
  end
end
