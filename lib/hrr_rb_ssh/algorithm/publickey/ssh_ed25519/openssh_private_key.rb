# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshEd25519
        module OpenSSHPrivateKey
          class << self
            include Codable
          end
          DEFINITION = [
            [DataType::String, :'cipher'],
            [DataType::String, :'kdfname'],
            [DataType::Uint32, :'kdfopts'],
            [DataType::Uint32, :'number of public keys'],
            [DataType::Uint32, :'first public key length'],
            [DataType::String, :'name'],
            [DataType::String, :'public key'],
            [DataType::String, :'content'],
          ]
        end
      end
    end
  end
end
