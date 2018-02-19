# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/data_type'

module HrrRbSsh
  module Message
    module Codable
      def encode payload
        definition.map{ |data_type, field_name|
          HrrRbSsh::Transport::DataType[data_type].encode( payload[field_name] )
        }.join
      end

      def decode payload
        payload_io = StringIO.new payload, 'r'
        definition.map{ |data_type, field_name|
          [
            field_name,
            HrrRbSsh::Transport::DataType[data_type].decode( payload_io )
          ]
        }.to_h
      end
    end
  end
end
