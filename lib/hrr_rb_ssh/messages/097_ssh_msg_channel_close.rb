require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_CHANNEL_CLOSE
      include Codable

      ID    = self.name.split('::').last
      VALUE = 97

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'recipient channel'],
      ]
    end
  end
end
