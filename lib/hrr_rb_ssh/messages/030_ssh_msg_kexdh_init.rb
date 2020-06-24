require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_KEXDH_INIT
      include Codable

      ID    = self.name.split('::').last
      VALUE = 30

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Mpint,     :'e'],
      ]
    end
  end
end
