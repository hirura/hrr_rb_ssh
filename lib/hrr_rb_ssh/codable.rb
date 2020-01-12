# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  module Codable
    include Loggable

    def initialize logger: nil
      self.logger = logger
    end

    def common_definition
      self.class::DEFINITION
    end

    def conditional_definition message
      return [] unless self.class.const_defined? :CONDITIONAL_DEFINITION
      message.inject([]){ |a, (k,v)|
        field_name  = k
        field_value = if v.instance_of? ::Proc then v.call else v end
        a + (self.class::CONDITIONAL_DEFINITION.fetch(field_name, {})[field_value] || [])
      }
    end

    def encode message, complementary_message={}
      log_debug { 'encoding message: ' + message.inspect }
      definition = common_definition + conditional_definition(message.merge complementary_message)
      definition.map{ |data_type, field_name|
        begin
          field_value = if message[field_name].instance_of? ::Proc then message[field_name].call else message[field_name] end
          data_type.encode field_value
        rescue => e
          log_debug { "'field_name', 'field_value': #{field_name.inspect}, #{field_value.inspect}" }
          raise e
        end
      }.join
    end

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
            data_type.decode(payload_io)
          ]
        }
        decoded_message + decode_recursively(payload_io, decoded_message)
      end
    end

    def decode payload, complementary_message={}
      payload_io = StringIO.new payload
      decoded_message = decode_recursively(payload_io).inject(Hash.new){ |h, (k, v)| h.update({k => v}) }
      if complementary_message.any?
        decoded_message.merge! decode_recursively(payload_io, complementary_message.to_a).inject(Hash.new){ |h, (k, v)| h.update({k => v}) }
      end
      log_debug { 'decoded message: ' + decoded_message.inspect }
      decoded_message
    end
  end
end
