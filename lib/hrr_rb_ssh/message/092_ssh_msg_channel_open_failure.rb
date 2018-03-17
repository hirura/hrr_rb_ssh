# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_CHANNEL_OPEN_FAILURE
      module ReasonCode
        SSH_OPEN_ADMINISTRATIVELY_PROHIBITED = 1
        SSH_OPEN_CONNECT_FAILED              = 2
        SSH_OPEN_UNKNOWN_CHANNEL_TYPE        = 3
        SSH_OPEN_RESOURCE_SHORTAGE           = 4
      end

      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 92

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_CHANNEL_OPEN_FAILURE'],
        ['uint32',    'recipient channel'],
        ['uint32',    'reason code'],
        ['string',    'description'],
        ['string',    'language tag'],
      ]
    end
  end
end
