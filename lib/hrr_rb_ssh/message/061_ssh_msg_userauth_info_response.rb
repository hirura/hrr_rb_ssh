# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_USERAUTH_INFO_RESPONSE
      include Codable

      ID    = self.name.split('::').last
      VALUE = 61

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::Uint32,    :'num-responses'],
      ]

      PER_NUM_RESPONSES_DEFINITION = Hash.new{ |hash, key|
        Array.new(key){ |i|
          [
            #[DataType, Field Name]
            #[DataType::String,   :'num-responses' : "> 0"],
            [DataType::String,    :"response[#{i+1}]"],
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
