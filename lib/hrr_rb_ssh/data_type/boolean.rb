# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    # Boolean provides methods to convert boolean value and 8-bit unsigned binary string each other.
    class Boolean < DataType
      # Convert boolean value into 8-bit unsigned binary string.
      #
      # @param [::Boolean] arg boolean value to be converted
      # @raise [::ArgumentError] when arg is not true nor false
      # @return [::String] converted 8-bit unsigned binary string
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

      # Convert 8-bit unsigned binary into boolean value.
      #
      # @param [::IO] io IO instance that has buffer to be read
      # @return [::Boolean] converted boolean value
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
