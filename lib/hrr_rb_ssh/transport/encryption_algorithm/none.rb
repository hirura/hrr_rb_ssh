# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/encryption_algorithm/unfunctionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class None < EncryptionAlgorithm
        NAME        = 'none'
        PREFERENCE  = 0
        BLOCK_SIZE  = 0
        include Unfunctionable
      end
    end
  end
end
