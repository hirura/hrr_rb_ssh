# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message/codable'

module HrrRbSsh
  module Message
    module SSH_MSG_USERAUTH_REQUEST
      class << self
        include Codable
      end

      ID    = self.name.split('::').last
      VALUE = 50

      DEFINITION = [
        # [Data Type, Field Name]
        ['byte',      'message number'],
        ['string',    'user name'],
        ['string',    'service name'],
        ['string',    'method name'],
      ]

      PUBLICKEY_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'method name' : "publickey"],
        ['boolean',   'with signature'],
        ['string',    'public key algorithm name'],
        ['string',    'public key blob'],
      ]

      PUBLICKEY_SIGNATURE_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'with signature' : "TRUE"],
        ['string',    'signature'],
      ]

      PASSWORD_DEFINITION = [
        # [Data Type, Field Name]
        # ['string',  'method name' : "password"],
        ['boolean',   'FALSE'],
        ['string',    'plaintext password'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        'method name' => {
          'publickey' => PUBLICKEY_DEFINITION,
          'password'  => PASSWORD_DEFINITION,
        },
        'with signature' => {
          true => PUBLICKEY_SIGNATURE_DEFINITION,
        },
      }
    end
  end
end
