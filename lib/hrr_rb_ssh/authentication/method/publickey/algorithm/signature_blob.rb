# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SignatureBlob
            include Codable
            DEFINITION = [
              [DataType::String,  :'session identifier'],
              [DataType::Byte,    :'message number'],
              [DataType::String,  :'user name'],
              [DataType::String,  :'service name'],
              [DataType::String,  :'method name'],
              [DataType::Boolean, :'with signature'],
              [DataType::String,  :'public key algorithm name'],
              [DataType::String,  :'public key blob'],
            ]
          end
        end
      end
    end
  end
end
