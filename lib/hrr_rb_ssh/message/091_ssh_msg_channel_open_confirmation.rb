# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_OPEN_CONFIRMATION
      include Codable

      ID    = self.name.split('::').last
      VALUE = 91

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'recipient channel'],
        [DataType::Uint32,    :'sender channel'],
        [DataType::Uint32,    :'initial window size'],
        [DataType::Uint32,    :'maximum packet size'],
      ]

      SESSION_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'channel type' : "session"],
      ]

      X11_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'channel type' : "x11"],
      ]

      FORWARDED_TCPIP_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'channel type' : "forwarded-tcpip"],
      ]

      DIRECT_TCPIP_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'channel type' : "direct-tcpip"],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'channel type' => {
          "session"         => SESSION_DEFINITION,
          "x11"             => X11_DEFINITION,
          "forwarded-tcpip" => FORWARDED_TCPIP_DEFINITION,
          "direct-tcpip"    => DIRECT_TCPIP_DEFINITION,
        },
      }
    end
  end
end
