require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Aes256Ctr < EncryptionAlgorithm
        NAME        = 'aes256-ctr'
        PREFERENCE  = 170
        CIPHER_NAME = "AES-256-CTR"
        BLOCK_SIZE  = 16
        include Functionable
      end
    end
  end
end
