# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_USERAUTH_PK_OK
      include Codable

      ID    = self.name.split('::').last
      VALUE = 60

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::String,    :'public key algorithm name from the request'],
        [DataType::String,    :'public key blob from the request'],
      ]
    end
  end
end
