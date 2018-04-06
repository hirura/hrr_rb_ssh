# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/mac_algorithm'
require 'hrr_rb_ssh/transport/mac_algorithm/unfunctionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class None < MacAlgorithm
        NAME   = 'none'

        DIGEST_LENGTH = 0
        KEY_LENGTH    = 0

        def initialize key=nil
          super
        end

        include Unfunctionable
      end
    end
  end
end
