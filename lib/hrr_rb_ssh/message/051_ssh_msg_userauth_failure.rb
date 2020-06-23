# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_USERAUTH_FAILURE
      include Codable

      ID    = self.name.split('::').last
      VALUE = 51

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::NameList,  :'authentications that can continue'],
        [DataTypes::Boolean,   :'partial success'],
      ]
    end
  end
end
