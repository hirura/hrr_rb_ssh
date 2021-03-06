require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_KEXECDH_REPLY
      include Codable

      ID    = self.name.split('::').last
      VALUE = 31

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'K_S'],
        [DataTypes::Mpint,     :'Q_S'],
        [DataTypes::String,    :'signature of H'],
      ]
    end
  end
end
