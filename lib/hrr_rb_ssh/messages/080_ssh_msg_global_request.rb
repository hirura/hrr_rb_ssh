require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_GLOBAL_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 80

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'request name'],
        [DataTypes::Boolean,   :'want reply'],
      ]

      TCPIP_FORWARD_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request name' : "tcpip-forward"],
        [DataTypes::String,    :'address to bind'],
        [DataTypes::Uint32,    :'port number to bind'],
      ]

      CANCEL_TCPIP_FORWARD_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'request name' : "cancel-tcpip-forward"],
        [DataTypes::String,    :'address to bind'],
        [DataTypes::Uint32,    :'port number to bind'],
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
