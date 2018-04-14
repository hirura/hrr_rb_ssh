# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class ThreeDesCbc < EncryptionAlgorithm
        NAME        = '3des-cbc'
        PREFERENCE  = 150
        CIPHER_NAME = "DES-EDE3-CBC"
        BLOCK_SIZE  = 8
        include Functionable
      end
    end
  end
end
