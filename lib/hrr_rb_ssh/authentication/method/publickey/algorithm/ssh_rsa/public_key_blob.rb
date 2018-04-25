# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SshRsa
            module PublicKeyBlob
              class << self
                include Codable
              end
              DEFINITION = [
                [DataType::String, :'public key algorithm name'],
                [DataType::Mpint,  :'e'],
                [DataType::Mpint,  :'n'],
              ]
            end
          end
        end
      end
    end
  end
end
