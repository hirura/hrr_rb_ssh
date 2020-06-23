# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_SERVICE_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 5

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'service name'],
      ]
    end
  end
end
