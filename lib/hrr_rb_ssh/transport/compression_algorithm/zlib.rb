# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/compression_algorithm/functionable'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      class Zlib < CompressionAlgorithm
        NAME = 'zlib'
        PREFERENCE = 10
        include Functionable
      end
    end
  end
end
