# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    class String < DataType
      def self.encode arg
        unless arg.kind_of? ::String
          raise ArgumentError, "must be a kind of String, but got #{arg.inspect}"
        end
        if arg.length > 0xffff_ffff
          raise ArgumentError, "must be shorter than or equal to #{0xffff_ffff}, but got length #{arg.length}"
        end
        [arg.length, arg].pack("Na*")
      end

      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0]
      end
    end
  end
end
