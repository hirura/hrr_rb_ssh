# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_KEXDH_INIT
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 30

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Mpint,     :'e'],
      ]
    end
  end
end
