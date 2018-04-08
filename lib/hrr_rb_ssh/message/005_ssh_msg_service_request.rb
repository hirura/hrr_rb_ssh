# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_SERVICE_REQUEST
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 5

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      'message number'],
        [DataType::String,    'service name'],
      ]
    end
  end
end
