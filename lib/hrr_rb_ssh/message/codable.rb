# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/data_type'

module HrrRbSsh
  module Message
    module Codable
      def logger
        @logger ||= HrrRbSsh::Logger.new self.name
      end

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
        logger.debug('encoding message: ' + message.inspect)
        definition = common_definition + conditional_definition(message)
        definition.map{ |data_type, field_name|
          field_value = if message[field_name].instance_of? ::Proc then message[field_name].call else message[field_name] end
          HrrRbSsh::Transport::DataType[data_type].encode( field_value )
        }.join
      end

      def decode payload
        def decode_recursively payload_io, message=nil
          if message.class == Array and message.size == 0
            []
          else
            definition = case message
                         when nil
                           common_definition
                         when Array
                           conditional_definition(message)
                         end
            additional_message = definition.map{ |data_type, field_name|
              [
                field_name,
                HrrRbSsh::Transport::DataType[data_type].decode( payload_io )
              ]
            }

            additional_message + decode_recursively(payload_io, additional_message)
          end
        end

        message = decode_recursively(StringIO.new payload).to_h
        logger.debug('decoded message: ' + message.inspect)
        message
      end
    end
  end
end
