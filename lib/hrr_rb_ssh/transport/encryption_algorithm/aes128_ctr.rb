# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Aes128Ctr < EncryptionAlgorithm
        NAME        = 'aes128-ctr'
        PREFERENCE  = 190
        CIPHER_NAME = "AES-128-CTR"
        BLOCK_SIZE  = 16
        include Functionable
      end
    end
  end
end
