# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/encryption_algorithm'
require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class ThreeDesCbc < EncryptionAlgorithm
        NAME        = '3des-cbc'
        CIPHER_NAME = "DES-EDE3-CBC"

        include Functionable
      end
    end
  end
end
