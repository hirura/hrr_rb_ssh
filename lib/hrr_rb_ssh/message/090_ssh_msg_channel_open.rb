# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_OPEN
      include Codable

      ID    = self.name.split('::').last
      VALUE = 90

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::String,    :'channel type'],
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
        [DataType::String,    :'originator address'],
        [DataType::Uint32,    :'originator port'],
      ]

      FORWARDED_TCPIP_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'channel type' : "forwarded-tcpip"],
        [DataType::String,    :'address that was connected'],
        [DataType::Uint32,    :'port that was connected'],
        [DataType::String,    :'originator IP address'],
        [DataType::Uint32,    :'originator port'],
      ]

      DIRECT_TCPIP_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'channel type' : "direct-tcpip"],
        [DataType::String,    :'host to connect'],
        [DataType::Uint32,    :'port to connect'],
        [DataType::String,    :'originator IP address'],
        [DataType::Uint32,    :'originator port'],
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
