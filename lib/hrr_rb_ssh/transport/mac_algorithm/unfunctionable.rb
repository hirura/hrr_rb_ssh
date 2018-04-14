# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      module Unfunctionable
        def initialize key=nil
          @logger = HrrRbSsh::Logger.new(self.class.name)
        end

        def digest_length
          self.class::DIGEST_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end

        def compute sequence_number, unencrypted_packet
          String.new
        end
      end
    end
  end
end
