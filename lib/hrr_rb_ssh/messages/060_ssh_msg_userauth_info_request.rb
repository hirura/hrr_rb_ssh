# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_USERAUTH_INFO_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 60

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'name'],
        [DataTypes::String,    :'instruction'],
        [DataTypes::String,    :'language tag'],
        [DataTypes::Uint32,    :'num-prompts'],
      ]

      PER_NUM_PROMPTS_DEFINITION = Hash.new{ |hash, key|
        Array.new(key){ |i|
          [
            #[DataTypes, Field Name]
            #[DataTypes::String,   :'num-prompts' : "> 0"],
            [DataTypes::String,    :"prompt[#{i+1}]"],
            [DataTypes::Boolean,   :"echo[#{i+1}]"],
          ]
        }.inject(:+)
      }

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'num-prompts' => PER_NUM_PROMPTS_DEFINITION,
      }
    end
  end
end
