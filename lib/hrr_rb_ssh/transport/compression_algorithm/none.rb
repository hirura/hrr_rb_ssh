# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/compression_algorithm/unfunctionable'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      class None < CompressionAlgorithm
        NAME = 'none'
        PREFERENCE = 20
        include Unfunctionable
      end
    end
  end
end
