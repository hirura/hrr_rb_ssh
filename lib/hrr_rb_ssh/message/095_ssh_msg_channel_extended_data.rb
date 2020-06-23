# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_EXTENDED_DATA
      module DataTypesCode
        SSH_EXTENDED_DATA_STDERR = 1
      end

      include Codable

      ID    = self.name.split('::').last
      VALUE = 95

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
        [DataTypes::Uint32,    :'data type code'],
        [DataTypes::String,    :'data'],
      ]
    end
  end
end
