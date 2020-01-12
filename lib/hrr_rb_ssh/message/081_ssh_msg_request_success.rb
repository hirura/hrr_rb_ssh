# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_REQUEST_SUCCESS
      include Codable

      ID    = self.name.split('::').last
      VALUE = 81

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
      ]

      TCPIP_FORWARD_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request name' : "tcpip-forward"],
        [DataType::Uint32,    :'port that was bound on the server'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'request name' => {
          "tcpip-forward" => TCPIP_FORWARD_DEFINITION,
        }
      }
    end
  end
end
