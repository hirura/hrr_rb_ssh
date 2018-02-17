# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      name_list = [
        'none'
      ]

      class None
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
        end

        def compute transport, packet
          String.new
        end

        def valid? transport, packet, mac
          mac == compute( transport, packet )
        end

        def length
          0
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = None
      end
    end
  end
end
