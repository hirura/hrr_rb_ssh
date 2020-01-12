# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_EOF
      include Codable

      ID    = self.name.split('::').last
      VALUE = 96

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'recipient channel'],
      ]
    end
  end
end
