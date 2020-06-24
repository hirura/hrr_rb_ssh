require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_USERAUTH_SUCCESS
      include Codable

      ID    = self.name.split('::').last
      VALUE = 52

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
      ]
    end
  end
end
