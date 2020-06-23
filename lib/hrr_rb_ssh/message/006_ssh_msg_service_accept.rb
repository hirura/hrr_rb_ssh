# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
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
