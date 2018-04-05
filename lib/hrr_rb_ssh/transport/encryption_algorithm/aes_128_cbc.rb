# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/encryption_algorithm'
require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Aes128Cbc < EncryptionAlgorithm
        NAME        = 'aes128-cbc'
        CIPHER_NAME = "AES-128-CBC"

        BLOCK_SIZE  = 16
        IV_LENGTH   = 16
        KEY_LENGTH  = 16

        def initialize iv, key
          super
        end

        include Functionable
      end
    end
  end
end
