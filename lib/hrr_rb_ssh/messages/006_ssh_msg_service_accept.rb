require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_SERVICE_ACCEPT
      include Codable

      ID    = self.name.split('::').last
      VALUE = 6

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'service name'],
      ]
    end
  end
end
