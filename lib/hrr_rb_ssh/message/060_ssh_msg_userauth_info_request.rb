# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_USERAUTH_INFO_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 60

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::String,    :'name'],
        [DataType::String,    :'instruction'],
        [DataType::String,    :'language tag'],
        [DataType::Uint32,    :'num-prompts'],
      ]

      PER_NUM_PROMPTS_DEFINITION = Hash.new{ |hash, key|
        Array.new(key){ |i|
          [
            #[DataType, Field Name]
            #[DataType::String,   :'num-prompts' : "> 0"],
            [DataType::String,    :"prompt[#{i+1}]"],
            [DataType::Boolean,   :"echo[#{i+1}]"],
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
