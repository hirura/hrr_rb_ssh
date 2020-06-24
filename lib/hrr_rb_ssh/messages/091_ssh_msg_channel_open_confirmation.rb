require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_CHANNEL_OPEN_CONFIRMATION
      include Codable

      ID    = self.name.split('::').last
      VALUE = 91

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
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
      ]

      FORWARDED_TCPIP_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'channel type' : "forwarded-tcpip"],
      ]

      DIRECT_TCPIP_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'channel type' : "direct-tcpip"],
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
