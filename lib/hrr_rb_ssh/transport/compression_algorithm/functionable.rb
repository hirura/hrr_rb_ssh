# coding: utf-8
# vim: et ts=2 sw=2

require 'zlib'
require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      module Functionable
        include Loggable

        def initialize direction, logger: nil
          self.logger = logger
          case direction
          when Direction::OUTGOING
            @deflator = ::Zlib::Deflate.new
          when Direction::INCOMING
            @inflator = ::Zlib::Inflate.new
          end
        end

        def deflate data
          @deflator.deflate(data, ::Zlib::SYNC_FLUSH)
        end

        def inflate data
          @inflator.inflate(data)
        end

        def close
          @deflator.close if @deflator && @deflator.closed?.!
          @inflator.close if @inflator && @inflator.closed?.!
        end
      end
    end
  end
end
