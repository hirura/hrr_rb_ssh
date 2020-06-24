require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_IGNORE
      include Codable

      ID    = self.name.split('::').last
      VALUE = 2

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'data'],
      ]
    end
  end
end
