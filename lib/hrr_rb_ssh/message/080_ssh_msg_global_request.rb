# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_GLOBAL_REQUEST
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 80

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_GLOBAL_REQUEST'],
        ['string',    'request name'],
        ['boolean',   'want reply'],
      ]

      TCPIP_FORWARD_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request name' : "tcpip-forward"],
        ['string',    'address to bind'],
        ['uint32',    'port number to bind'],
      ]

      CANCEL_TCPIP_FORWARD_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'request name' : "cancel-tcpip-forward"],
        ['string',    'address to bind'],
        ['uint32',    'port number to bind'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        'request name' => {
          'tcpip-forward'        => TCPIP_FORWARD_DEFINITION,
          'cancel-tcpip-forward' => CANCEL_TCPIP_FORWARD_DEFINITION,
        },
      }
    end
  end
end
