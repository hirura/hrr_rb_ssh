# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_KEX_DH_GEX_REQUEST_OLD
      include Codable

      ID    = self.name.split('::').last
      VALUE = 30

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'n'],
      ]
    end
  end
end
