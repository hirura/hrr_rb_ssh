# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_KEX_DH_GEX_GROUP
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 31

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      'message number'],
        [DataType::Mpint,     'p'],
        [DataType::Mpint,     'g'],
      ]
    end
  end
end
