# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    class Byte < DataType
      def self.encode arg
        case arg
        when 0x00..0xff
          [arg].pack("C")
        else
          raise ArgumentError, "must be in #{0x00}..#{0xff}, but got #{arg.inspect}"
        end
      end

      def self.decode io
        io.read(1).unpack("C")[0]
      end
    end
  end
end
