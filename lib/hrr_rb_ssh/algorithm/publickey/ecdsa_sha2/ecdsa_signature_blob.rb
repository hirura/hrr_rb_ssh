require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      module EcdsaSha2
        class EcdsaSignatureBlob
          include Codable
          DEFINITION = [
            [DataTypes::Mpint, :'r'],
            [DataTypes::Mpint, :'s'],
          ]
        end
      end
    end
  end
end
