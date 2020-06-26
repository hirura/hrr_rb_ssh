
module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Unfunctionable
        include Loggable

        def self.included klass
          klass.const_set(:IV_LENGTH,  0)
          klass.const_set(:KEY_LENGTH, 0)
        end

        def initialize direction=nil, iv=nil, key=nil, logger: nil
          self.logger = logger
        end

        def block_size
          self.class::BLOCK_SIZE
        end

        def iv_length
          self.class::IV_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end

        def encrypt data
          data
        end

        def decrypt data
          data
        end
      end
    end
  end
end
