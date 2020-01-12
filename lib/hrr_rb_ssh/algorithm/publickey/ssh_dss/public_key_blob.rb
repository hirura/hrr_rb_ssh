# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshDss
        class PublicKeyBlob
          include Codable
          DEFINITION = [
            [DataType::String, :'public key algorithm name'],
            [DataType::Mpint,  :'p'],
            [DataType::Mpint,  :'q'],
            [DataType::Mpint,  :'g'],
            [DataType::Mpint,  :'y'],
          ]
        end
      end
    end
  end
end
