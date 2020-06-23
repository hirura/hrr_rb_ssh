# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_CHANNEL_DATA
      include Codable

      ID    = self.name.split('::').last
      VALUE = 94

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
        [DataTypes::String,    :'data'],
      ]
    end
  end
end
