# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp384
        module EcdsaSignatureBlob
          class << self
            include Codable
          end
          DEFINITION = [
            [DataType::Mpint, :'r'],
            [DataType::Mpint, :'s'],
          ]
        end
      end
    end
  end
end
