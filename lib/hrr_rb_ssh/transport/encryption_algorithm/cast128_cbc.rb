# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class Cast128Cbc < EncryptionAlgorithm
        NAME        = 'cast128-cbc'
        PREFERENCE  = 130
        CIPHER_NAME = "CAST5-CBC"
        BLOCK_SIZE  = 8
        include Functionable
      end
    end
  end
end
