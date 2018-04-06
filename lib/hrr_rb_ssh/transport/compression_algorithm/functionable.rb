# coding: utf-8
# vim: et ts=2 sw=2

require 'zlib'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      module Functionable
        def initialize direction
          super

          case direction
          when HrrRbSsh::Transport::Direction::OUTGOING
            @deflator = ::Zlib::Deflate.new
          when HrrRbSsh::Transport::Direction::INCOMING
            @inflator = ::Zlib::Inflate.new
          end
        end

        def deflate data
          @deflator.deflate(data, ::Zlib::SYNC_FLUSH)
        end

        def inflate data
          @inflator.inflate(data)
        end
      end
    end
  end
end
