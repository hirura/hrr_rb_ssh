# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_EXTENDED_DATA
      module DataTypeCode
        SSH_EXTENDED_DATA_STDERR = 1
      end

      include Codable

      ID    = self.name.split('::').last
      VALUE = 95

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'recipient channel'],
        [DataType::Uint32,    :'data type code'],
        [DataType::String,    :'data'],
      ]
    end
  end
end
