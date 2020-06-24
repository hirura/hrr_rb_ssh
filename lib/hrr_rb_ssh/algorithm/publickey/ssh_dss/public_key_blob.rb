require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshDss
        class PublicKeyBlob
          include Codable
          DEFINITION = [
            [DataTypes::String, :'public key algorithm name'],
            [DataTypes::Mpint,  :'p'],
            [DataTypes::Mpint,  :'q'],
            [DataTypes::Mpint,  :'g'],
            [DataTypes::Mpint,  :'y'],
          ]
        end
      end
    end
  end
end
