# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/encryption_algorithm/unfunctionable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class None < EncryptionAlgorithm
        NAME = 'none'

        def initialize direction=nil, iv=nil, key=nil
          super
        end

        include Unfunctionable
      end
    end
  end
end
