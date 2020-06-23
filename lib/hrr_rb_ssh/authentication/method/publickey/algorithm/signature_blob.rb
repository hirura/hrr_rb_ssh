# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SignatureBlob
            include Codable
            DEFINITION = [
              [DataTypes::String,  :'session identifier'],
              [DataTypes::Byte,    :'message number'],
              [DataTypes::String,  :'user name'],
              [DataTypes::String,  :'service name'],
              [DataTypes::String,  :'method name'],
              [DataTypes::Boolean, :'with signature'],
              [DataTypes::String,  :'public key algorithm name'],
              [DataTypes::String,  :'public key blob'],
            ]
          end
        end
      end
    end
  end
end
