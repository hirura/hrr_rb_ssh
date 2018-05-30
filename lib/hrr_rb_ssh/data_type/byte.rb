# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    # Byte provides methods to convert integer value and 8-bit unsigned binary string each other.
    class Byte < DataType
      # Convert integer value into 8-bit unsigned binary string.
      #
      # @param [::Integer] arg integer value to be converted
      # @raise [::ArgumentError] when arg is not between 0x00 and 0xff
      # @return [::String] converted 8-bit unsigned binary string
      def self.encode arg
        case arg
        when 0x00..0xff
          [arg].pack("C")
        else
          raise ArgumentError, "must be in #{0x00}..#{0xff}, but got #{arg.inspect}"
        end
      end

      # Convert 8-bit unsigned binary into Integer value.
      #
      # @param [::IO] io IO instance that has buffer to be read
      # @return [::Integer] converted integer value
      def self.decode io
        io.read(1).unpack("C")[0]
      end
    end
  end
end
