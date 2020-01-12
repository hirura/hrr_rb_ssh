# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_DISCONNECT
      module ReasonCode
        SSH_DISCONNECT_HOST_NOT_ALLOWED_TO_CONNECT    =  1
        SSH_DISCONNECT_PROTOCOL_ERROR                 =  2
        SSH_DISCONNECT_KEY_EXCHANGE_FAILED            =  3
        SSH_DISCONNECT_RESERVED                       =  4
        SSH_DISCONNECT_MAC_ERROR                      =  5
        SSH_DISCONNECT_COMPRESSION_ERROR              =  6
        SSH_DISCONNECT_SERVICE_NOT_AVAILABLE          =  7
        SSH_DISCONNECT_PROTOCOL_VERSION_NOT_SUPPORTED =  8
        SSH_DISCONNECT_HOST_KEY_NOT_VERIFIABLE        =  9
        SSH_DISCONNECT_CONNECTION_LOST                = 10
        SSH_DISCONNECT_BY_APPLICATION                 = 11
        SSH_DISCONNECT_TOO_MANY_CONNECTIONS           = 12
        SSH_DISCONNECT_AUTH_CANCELLED_BY_USER         = 13
        SSH_DISCONNECT_NO_MORE_AUTH_METHODS_AVAILABLE = 14
        SSH_DISCONNECT_ILLEGAL_USER_NAME              = 15
      end

      include Codable

      ID    = self.name.split('::').last
      VALUE = 1

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'reason code'],
        [DataType::String,    :'description'],
        [DataType::String,    :'language tag'],
      ]
    end
  end
end
