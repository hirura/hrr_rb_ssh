# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_KEXDH_REPLY
      class << self
        include Codable

        def definition
          DEFINITION
        end
      end

      ID    = self.name.split('::').last
      VALUE = 31

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_KEXDH_REPLY'],
        ['string',    'server public host key and certificates (K_S)'],
        ['mpint',     'f'],
        ['string',    'signature of H'],
      ]
    end
  end
end
