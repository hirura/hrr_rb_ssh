# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      module EcdsaSha2
        class EcdsaSignatureBlob
          include Codable
          DEFINITION = [
            [DataType::Mpint, :'r'],
            [DataType::Mpint, :'s'],
          ]
        end
      end
    end
  end
end
