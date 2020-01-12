# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_GLOBAL_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 80

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::String,    :'request name'],
        [DataType::Boolean,   :'want reply'],
      ]

      TCPIP_FORWARD_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request name' : "tcpip-forward"],
        [DataType::String,    :'address to bind'],
        [DataType::Uint32,    :'port number to bind'],
      ]

      CANCEL_TCPIP_FORWARD_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'request name' : "cancel-tcpip-forward"],
        [DataType::String,    :'address to bind'],
        [DataType::Uint32,    :'port number to bind'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'request name' => {
          "tcpip-forward"        => TCPIP_FORWARD_DEFINITION,
          "cancel-tcpip-forward" => CANCEL_TCPIP_FORWARD_DEFINITION,
        },
      }
    end
  end
end
