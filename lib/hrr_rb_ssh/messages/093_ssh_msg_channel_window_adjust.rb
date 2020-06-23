# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_CHANNEL_WINDOW_ADJUST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 93

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
        [DataTypes::Uint32,    :'bytes to add'],
      ]
    end
  end
end
