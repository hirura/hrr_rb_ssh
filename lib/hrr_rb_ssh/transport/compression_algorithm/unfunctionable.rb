# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      module Unfunctionable
        def deflate data
          data
        end

        def inflate data
          data
        end
      end
    end
  end
end
