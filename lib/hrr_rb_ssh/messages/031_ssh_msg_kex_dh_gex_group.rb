require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_KEX_DH_GEX_GROUP
      include Codable

      ID    = self.name.split('::').last
      VALUE = 31

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Mpint,     :'p'],
        [DataTypes::Mpint,     :'g'],
      ]
    end
  end
end
