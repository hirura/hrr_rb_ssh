# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module DiffieHellman
        class H0
          include Codable
          DEFINITION = [
            [DataTypes::String, :'V_C'],
            [DataTypes::String, :'V_S'],
            [DataTypes::String, :'I_C'],
            [DataTypes::String, :'I_S'],
            [DataTypes::String, :'K_S'],
            [DataTypes::Mpint,  :'e'],
            [DataTypes::Mpint,  :'f'],
            [DataTypes::Mpint,  :'k'],
          ]
        end
      end
    end
  end
end
