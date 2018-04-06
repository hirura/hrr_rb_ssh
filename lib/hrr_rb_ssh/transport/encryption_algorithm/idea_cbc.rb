# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/encryption_algorithm'
require 'hrr_rb_ssh/transport/encryption_algorithm/functionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class IdeaCbc < EncryptionAlgorithm
        NAME        = 'idea-cbc'
        CIPHER_NAME = "IDEA-CBC"
        BLOCK_SIZE  = 8

        include Functionable
      end
    end
  end
end
