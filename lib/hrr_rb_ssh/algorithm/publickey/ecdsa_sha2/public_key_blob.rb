require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      module EcdsaSha2
        class PublicKeyBlob
          include Codable
          DEFINITION = [
            [DataTypes::String, :'public key algorithm name'],
            [DataTypes::String, :'identifier'],
            [DataTypes::String, :'Q'],
          ]
        end
      end
    end
  end
end
