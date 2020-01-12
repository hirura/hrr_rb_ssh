# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Message
    class SSH_MSG_USERAUTH_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 50

      DEFINITION = [
        #[DataType, Field Name]
        [DataType::Byte,      :'message number'],
        [DataType::String,    :'user name'],
        [DataType::String,    :'service name'],
        [DataType::String,    :'method name'],
      ]

      PUBLICKEY_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'method name' : "publickey"],
        [DataType::Boolean,   :'with signature'],
        [DataType::String,    :'public key algorithm name'],
        [DataType::String,    :'public key blob'],
      ]

      PUBLICKEY_SIGNATURE_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'with signature' : "TRUE"],
        [DataType::String,    :'signature'],
      ]

      PASSWORD_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'method name' : "password"],
        [DataType::Boolean,   :'FALSE'],
        [DataType::String,    :'plaintext password'],
      ]

      KEYBOARD_INTERACTIVE_DEFINITION = [
        #[DataType, Field Name]
        #[DataType::String,   :'method name' : "keyboard-interactive"],
        [DataType::String,    :'language tag'],
        [DataType::String,    :'submethods'],
      ]

      CONDITIONAL_DEFINITION = {
        # Field Name => {Field Value => Conditional Definition}
        :'method name' => {
          "publickey"             => PUBLICKEY_DEFINITION,
          "password"              => PASSWORD_DEFINITION,
          "keyboard-interactive"  => KEYBOARD_INTERACTIVE_DEFINITION,
        },
        :'with signature' => {
          true => PUBLICKEY_SIGNATURE_DEFINITION,
        },
      }
    end
  end
end
