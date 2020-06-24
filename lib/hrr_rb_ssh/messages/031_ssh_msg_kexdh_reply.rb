require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_KEXDH_REPLY
      include Codable

      ID    = self.name.split('::').last
      VALUE = 31

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'server public host key and certificates (K_S)'],
        [DataTypes::Mpint,     :'f'],
        [DataTypes::String,    :'signature of H'],
      ]
    end
  end
end
