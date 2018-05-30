# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    # Uint64 provides methods to convert integer value and 64-bit unsigned binary string each other.
    class Uint64 < DataType
      # Convert integer value into 64-bit unsigned binary string.
      #
      # @param [::Integer] arg integer value to be converted
      # @raise [::ArgumentError] when arg is not between 0x0000_0000_0000_0000 and 0xffff_ffff_ffff_ffff
      # @return [::String] converted 64-bit unsigned binary string
      def self.encode arg
        case arg
        when 0x0000_0000_0000_0000..0xffff_ffff_ffff_ffff
          [arg >> 32].pack("N") + [arg & 0x0000_0000_ffff_ffff].pack("N")
        else
          raise ArgumentError, "must be in #{0x0000_0000_0000_0000}..#{0xffff_ffff_ffff_ffff}, but got #{arg.inspect}"
        end
      end

      # Convert 64-bit unsigned binary into Integer value.
      #
      # @param [::IO] io IO instance that has buffer to be read
      # @return [::Integer] converted integer value
      def self.decode io
        (io.read(4).unpack("N")[0] << 32) + (io.read(4).unpack("N")[0])
      end
    end
  end
end
