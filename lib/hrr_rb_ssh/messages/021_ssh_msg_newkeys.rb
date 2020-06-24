require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_NEWKEYS
      include Codable

      ID    = self.name.split('::').last
      VALUE = 21

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
      ]
    end
  end
end
