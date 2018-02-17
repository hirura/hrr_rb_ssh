# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class SequenceNumber
      attr_reader :sequence_number

      def initialize
        @sequence_number = 0

        @logger = HrrRbSsh::Logger.new self.class.name
      end

      def increment
        @sequence_number = (@sequence_number + 1) % 0x1_0000_0000
      end
    end
  end
end
