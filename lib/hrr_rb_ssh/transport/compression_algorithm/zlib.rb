# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/compression_algorithm/compression_algorithm'
require 'hrr_rb_ssh/transport/compression_algorithm/functionable'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      class Zlib < CompressionAlgorithm
        NAME = 'zlib'

        def initialize direction
          super
        end

        include Functionable
      end
    end
  end
end
