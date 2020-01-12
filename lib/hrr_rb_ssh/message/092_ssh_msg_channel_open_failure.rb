# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_OPEN_FAILURE
      module ReasonCode
        SSH_OPEN_ADMINISTRATIVELY_PROHIBITED = 1
        SSH_OPEN_CONNECT_FAILED              = 2
        SSH_OPEN_UNKNOWN_CHANNEL_TYPE        = 3
        SSH_OPEN_RESOURCE_SHORTAGE           = 4
      end

      include Codable

      ID    = self.name.split('::').last
      VALUE = 92

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'recipient channel'],
        [DataType::Uint32,    :'reason code'],
        [DataType::String,    :'description'],
        [DataType::String,    :'language tag'],
      ]
    end
  end
end
