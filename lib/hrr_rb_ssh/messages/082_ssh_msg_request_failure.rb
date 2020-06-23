# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_REQUEST_FAILURE
      include Codable

      ID    = self.name.split('::').last
      VALUE = 82

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
      ]
    end
  end
end
