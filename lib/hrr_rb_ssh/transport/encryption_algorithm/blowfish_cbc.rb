# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/encryption_algorithm'
require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class BlowfishCbc < EncryptionAlgorithm
        NAME        = 'blowfish-cbc'
        CIPHER_NAME = "BF-CBC"

        include Functionable
      end
    end
  end
end
