# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class BlowfishCbc < EncryptionAlgorithm
        NAME        = 'blowfish-cbc'
        PREFERENCE  = 140
        CIPHER_NAME = "BF-CBC"
        BLOCK_SIZE  = 8
        include Functionable
      end
    end
  end
end
