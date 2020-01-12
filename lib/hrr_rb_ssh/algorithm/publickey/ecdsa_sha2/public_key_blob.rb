# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      module EcdsaSha2
        class PublicKeyBlob
          include Codable
          DEFINITION = [
            [DataType::String, :'public key algorithm name'],
            [DataType::String, :'identifier'],
            [DataType::String, :'Q'],
          ]
        end
      end
    end
  end
end
