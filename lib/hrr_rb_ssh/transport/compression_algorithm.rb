# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      def self.list
        CompressionAlgorithm.list
      end

      def self.name_list
        CompressionAlgorithm.name_list
      end

      def self.[] key
        CompressionAlgorithm[key]
      end
    end
  end
end

require 'hrr_rb_ssh/transport/compression_algorithm/compression_algorithm'
require 'hrr_rb_ssh/transport/compression_algorithm/none'
require 'hrr_rb_ssh/transport/compression_algorithm/zlib'
