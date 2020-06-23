# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_UNIMPLEMENTED
      include Codable

      ID    = self.name.split('::').last
      VALUE = 3

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'packet sequence number of rejected message'],
      ]
    end
  end
end
