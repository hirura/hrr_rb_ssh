# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/data_type'

module HrrRbSsh
  module Message
    module Codable
      def encode payload
        definition.map{ |data_type, field_name|
          field_value = if payload[field_name].instance_of? ::Proc then payload[field_name].call else payload[field_name] end
          HrrRbSsh::Transport::DataType[data_type].encode( field_value )
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
