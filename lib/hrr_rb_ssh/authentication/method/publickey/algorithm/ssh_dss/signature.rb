# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SshDss
            module Signature
              class << self
                include Codable
              end
              DEFINITION = [
                [DataType::String, :'public key algorithm name'],
                [DataType::String, :'signature blob'],
              ]
            end
          end
        end
      end
    end
  end
end
