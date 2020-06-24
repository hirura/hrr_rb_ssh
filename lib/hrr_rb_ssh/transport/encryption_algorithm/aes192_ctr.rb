require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Aes192Ctr < EncryptionAlgorithm
        NAME        = 'aes192-ctr'
        PREFERENCE  = 180
        CIPHER_NAME = "AES-192-CTR"
        BLOCK_SIZE  = 16
        include Functionable
      end
    end
  end
end
