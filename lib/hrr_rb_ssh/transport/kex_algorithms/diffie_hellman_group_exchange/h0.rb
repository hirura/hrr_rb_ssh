module HrrRbSsh
  class Transport
    class KexAlgorithms
      module DiffieHellmanGroupExchange
        class H0
          include Codable
          DEFINITION = [
            [DataTypes::String, :'V_C'],
            [DataTypes::String, :'V_S'],
            [DataTypes::String, :'I_C'],
            [DataTypes::String, :'I_S'],
            [DataTypes::String, :'K_S'],
            [DataTypes::Uint32, :'min'],
            [DataTypes::Uint32, :'n'],
            [DataTypes::Uint32, :'max'],
            [DataTypes::Mpint,  :'p'],
            [DataTypes::Mpint,  :'g'],
            [DataTypes::Mpint,  :'e'],
            [DataTypes::Mpint,  :'f'],
            [DataTypes::Mpint,  :'k'],
          ]
        end
      end
    end
  end
end
