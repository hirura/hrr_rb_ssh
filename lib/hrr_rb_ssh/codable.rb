# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
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

    def encode message, complementary_message={}
      logger.debug('encoding message: ' + message.inspect)
      definition = common_definition + conditional_definition(message.merge complementary_message)
      definition.map{ |data_type, field_name|
        field_value = if message[field_name].instance_of? ::Proc then message[field_name].call else message[field_name] end
        data_type.encode( field_value )
      }.join
    end

    def decode payload, complementary_message={}
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
          decoded_message = definition.map{ |data_type, field_name|
            [
              field_name,
              data_type.decode( payload_io )
            ]
          }

          decoded_message + decode_recursively(payload_io, decoded_message)
        end
      end

      payload_io = StringIO.new payload
      decoded_message = decode_recursively(payload_io).to_h
      if complementary_message.any?
        decoded_message.merge! decode_recursively(payload_io, complementary_message.to_a).to_h
      end
      logger.debug('decoded message: ' + decoded_message.inspect)
      decoded_message
    end
  end
end
