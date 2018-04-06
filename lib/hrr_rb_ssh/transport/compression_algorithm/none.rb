# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/compression_algorithm/compression_algorithm'
require 'hrr_rb_ssh/transport/compression_algorithm/unfunctionable'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      class None < CompressionAlgorithm
        NAME = 'none'

        def initialize direction=nil
          super
        end

        include Unfunctionable
      end
    end
  end
end
