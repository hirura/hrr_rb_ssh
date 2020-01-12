# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class SequenceNumber
      attr_reader :sequence_number

      def initialize
        @sequence_number = 0
      end

      def increment
        @sequence_number = (@sequence_number + 1) % 0x1_0000_0000
      end
    end
  end
end
