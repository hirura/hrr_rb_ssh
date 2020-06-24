require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Arcfour < EncryptionAlgorithm
        NAME        = 'arcfour'
        PREFERENCE  = 100
        CIPHER_NAME = "RC4"
        BLOCK_SIZE  = 8
        include Functionable
      end
    end
  end
end
