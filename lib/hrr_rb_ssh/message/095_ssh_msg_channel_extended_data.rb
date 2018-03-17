# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_CHANNEL_EXTENDED_DATA
      module DataTypeCode
        SSH_EXTENDED_DATA_STDERR = 1
      end

      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 95

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_CHANNEL_EXTENDED_DATA'],
        ['uint32',    'recipient channel'],
        ['uint32',    'data type code'],
        ['string',    'data'],
      ]
    end
  end
end
