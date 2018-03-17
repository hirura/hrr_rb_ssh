# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_REQUEST_SUCCESS
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 81

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_REQUEST_SUCCESS'],
      ]

      TCPIP_FORWARD_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request name' : "tcpip-forward"],
        ['uint32',    'port that was bound on the server'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        'request name' => {
          'tcpip-forward' => TCPIP_FORWARD_DEFINITION,
        }
      }
    end
  end
end
