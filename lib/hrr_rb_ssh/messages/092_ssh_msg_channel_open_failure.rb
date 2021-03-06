require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_CHANNEL_OPEN_FAILURE
      module ReasonCode
        SSH_OPEN_ADMINISTRATIVELY_PROHIBITED = 1
        SSH_OPEN_CONNECT_FAILED              = 2
        SSH_OPEN_UNKNOWN_CHANNEL_TYPE        = 3
        SSH_OPEN_RESOURCE_SHORTAGE           = 4
      end

      include Codable

      ID    = self.name.split('::').last
      VALUE = 92

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
        [DataTypes::Uint32,    :'reason code'],
        [DataTypes::String,    :'description'],
        [DataTypes::String,    :'language tag'],
      ]
    end
  end
end
