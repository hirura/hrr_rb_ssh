# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_USERAUTH_PK_OK
      include Codable

      ID    = self.name.split('::').last
      VALUE = 60

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'public key algorithm name from the request'],
        [DataTypes::String,    :'public key blob from the request'],
      ]
    end
  end
end
