# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_CHANNEL_OPEN_CONFIRMATION
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 91

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'message number'],
        ['uint32',    'recipient channel'],
        ['uint32',    'sender channel'],
        ['uint32',    'initial window size'],
        ['uint32',    'maximum packet size'],
      ]

      SESSION_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'channel type' : "session"],
      ]

      X11_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'channel type' : "x11"],
        ['string',    'originator address'],
        ['uint32',    'originator port'],
      ]

      FORWARDED_TCPIP_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'channel type' : "forwarded-tcpip"],
        ['string',    'address that was connected'],
        ['uint32',    'port that was connected'],
        ['string',    'originator IP address'],
        ['uint32',    'originator port'],
      ]

      DIRECT_TCPIP_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'channel type' : "direct-tcpip"],
        ['string',    'host to connect'],
        ['uint32',    'port to connect'],
        ['string',    'originator IP address'],
        ['uint32',    'originator port'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        'channel type' => {
          'session'         => SESSION_DEFINITION,
          'x11'             => X11_DEFINITION,
          'forwarded-tcpip' => FORWARDED_TCPIP_DEFINITION,
          'direct-tcpip'    => DIRECT_TCPIP_DEFINITION,
        },
      }
    end
  end
end
