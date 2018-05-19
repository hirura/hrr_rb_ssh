# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      module EcdsaSha2
        module Signature
          class << self
            include Codable
          end
          DEFINITION = [
            [DataType::String, :'public key algorithm name'],
            [DataType::String, :'ecdsa signature blob'],
          ]
        end
      end
    end
  end
end
