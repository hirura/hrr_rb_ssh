# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_USERAUTH_PK_OK
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 60

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'SSH_MSG_USERAUTH_PK_OK'],
        ['string',    'public key algorithm name from the request'],
        ['string',    'public key blob from the request'],
      ]
    end
  end
end
