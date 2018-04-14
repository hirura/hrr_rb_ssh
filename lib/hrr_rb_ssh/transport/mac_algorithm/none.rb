# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/unfunctionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class None < MacAlgorithm
        NAME       = 'none'
        PREFERENCE = 0
        DIGEST_LENGTH = 0
        KEY_LENGTH    = 0
        include Unfunctionable
      end
    end
  end
end
