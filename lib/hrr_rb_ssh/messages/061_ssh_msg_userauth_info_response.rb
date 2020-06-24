require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_USERAUTH_INFO_RESPONSE
      include Codable

      ID    = self.name.split('::').last
      VALUE = 61

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::Uint32,    :'num-responses'],
      ]

      PER_NUM_RESPONSES_DEFINITION = Hash.new{ |hash, key|
        Array.new(key){ |i|
          [
            #[DataTypes, Field Name]
            #[DataTypes::String,   :'num-responses' : "> 0"],
            [DataTypes::String,    :"response[#{i+1}]"],
          ]
        }.inject(:+)
      }

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'num-responses' => PER_NUM_RESPONSES_DEFINITION,
      }
    end
  end
end
