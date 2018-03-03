# coding: utf-8
# vim: et ts=2 sw=2

require 'zlib'

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      name_list = [
        'zlib'
      ]

      class Zlib
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name

          @deflator = ::Zlib::Deflate.new
          @inflator = ::Zlib::Inflate.new
        end

        def deflate data
          @deflator.deflate(data, ::Zlib::SYNC_FLUSH)
        end

        def inflate data
          @inflator.inflate(data)
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = Zlib
      end
    end
  end
end
