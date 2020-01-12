# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module DiffieHellman
        class H0
          include Codable
          DEFINITION = [
            [DataType::String, :'V_C'],
            [DataType::String, :'V_S'],
            [DataType::String, :'I_C'],
            [DataType::String, :'I_S'],
            [DataType::String, :'K_S'],
            [DataType::Mpint,  :'e'],
            [DataType::Mpint,  :'f'],
            [DataType::Mpint,  :'k'],
          ]
        end
      end
    end
  end
end
