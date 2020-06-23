# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_CHANNEL_OPEN
      include Codable

      ID    = self.name.split('::').last
      VALUE = 90

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'channel type'],
        [DataTypes::Uint32,    :'sender channel'],
        [DataTypes::Uint32,    :'initial window size'],
        [DataTypes::Uint32,    :'maximum packet size'],
      ]

      SESSION_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'channel type' : "session"],
      ]

      X11_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'channel type' : "x11"],
        [DataTypes::String,    :'originator address'],
        [DataTypes::Uint32,    :'originator port'],
      ]

      FORWARDED_TCPIP_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'channel type' : "forwarded-tcpip"],
        [DataTypes::String,    :'address that was connected'],
        [DataTypes::Uint32,    :'port that was connected'],
        [DataTypes::String,    :'originator IP address'],
        [DataTypes::Uint32,    :'originator port'],
      ]

      DIRECT_TCPIP_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'channel type' : "direct-tcpip"],
        [DataTypes::String,    :'host to connect'],
        [DataTypes::Uint32,    :'port to connect'],
        [DataTypes::String,    :'originator IP address'],
        [DataTypes::Uint32,    :'originator port'],
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
