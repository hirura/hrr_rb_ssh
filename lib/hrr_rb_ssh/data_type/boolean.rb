# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    class Boolean < DataType
      def self.encode arg
        case arg
        when false
          [0].pack("C")
        when true
          [1].pack("C")
        else
          raise ArgumentError, "must be #{true} or #{false}, but got #{arg.inspect}"
        end
      end

      def self.decode io
        if 0 == io.read(1).unpack("C")[0]
          false
        else
          true
        end
      end
    end
  end
end
