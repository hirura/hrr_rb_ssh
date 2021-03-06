require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Aes256Cbc < EncryptionAlgorithm
        NAME        = 'aes256-cbc'
        PREFERENCE  = 110
        CIPHER_NAME = "AES-256-CBC"
        BLOCK_SIZE  = 16
        include Functionable
      end
    end
  end
end
