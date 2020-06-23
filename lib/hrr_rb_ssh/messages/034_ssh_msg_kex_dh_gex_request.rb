# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_KEX_DH_GEX_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 34

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'min'],
        [DataTypes::Uint32,    :'n'],
        [DataTypes::Uint32,    :'max'],
      ]
    end
  end
end
