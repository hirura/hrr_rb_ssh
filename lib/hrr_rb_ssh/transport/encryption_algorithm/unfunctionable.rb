# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Unfunctionable
        def self.included klass
          klass.const_set(:BLOCK_SIZE, 0)
          klass.const_set(:IV_LENGTH,  0)
          klass.const_set(:KEY_LENGTH, 0)
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
