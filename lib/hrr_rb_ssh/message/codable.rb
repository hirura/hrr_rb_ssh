# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/data_type'

module HrrRbSsh
  module Message
    module Codable
      def common_definition
        self::DEFINITION
      end

      def conditional_definition message
        message.inject([]){ |a, (k,v)|
          field_name  = k
          field_value = if v.instance_of? ::Proc then v.call else v end
          a + ((self::CONDITIONAL_DEFINITION rescue {}).fetch(field_name, {})[field_value] || [])
        }
      end

      def encode message
        definition = common_definition + conditional_definition(message)
        definition.map{ |data_type, field_name|
          field_value = if message[field_name].instance_of? ::Proc then message[field_name].call else message[field_name] end
          HrrRbSsh::Transport::DataType[data_type].encode( field_value )
        }.join
      end

      def decode payload
        payload_io = StringIO.new payload, 'r'
        common_message = common_definition.map{ |data_type, field_name|
          [
            field_name,
            HrrRbSsh::Transport::DataType[data_type].decode( payload_io )
          ]
        }
        conditional_message = conditional_definition(common_message).map{ |data_type, field_name|
          [
            field_name,
            HrrRbSsh::Transport::DataType[data_type].decode( payload_io )
          ]
        }
        (common_message + conditional_message).to_h
      end
    end
  end
end
