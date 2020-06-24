require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Aes128Cbc < EncryptionAlgorithm
        NAME        = 'aes128-cbc'
        PREFERENCE  = 160
        CIPHER_NAME = "AES-128-CBC"
        BLOCK_SIZE  = 16
        include Functionable
      end
    end
  end
end
