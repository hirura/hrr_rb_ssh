# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshEd25519
        module OpenSSHPrivateKeyContent
          class << self
            include Codable
          end
          DEFINITION = [
            [DataType::Uint64, :'unknown'],
            [DataType::String, :'name'],
            [DataType::String, :'public key'],
            [DataType::String, :'key pair'],
            [DataType::String, :'padding'],
          ]
        end
      end
    end
  end
end
