# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_DEBUG
      include Codable

      ID    = self.name.split('::').last
      VALUE = 4

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Boolean,   :'always_display'],
        [DataTypes::String,    :'message'],
        [DataTypes::String,    :'language tag'],
      ]
    end
  end
end
