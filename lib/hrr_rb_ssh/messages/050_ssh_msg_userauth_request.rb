require 'hrr_rb_ssh/codable'

module HrrRbSsh
  module Messages
    class SSH_MSG_USERAUTH_REQUEST
      include Codable

      ID    = self.name.split('::').last
      VALUE = 50

      DEFINITION = [
        #[DataTypes, Field Name]
        [DataTypes::Byte,      :'message number'],
        [DataTypes::String,    :'user name'],
        [DataTypes::String,    :'service name'],
        [DataTypes::String,    :'method name'],
      ]

      PUBLICKEY_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'method name' : "publickey"],
        [DataTypes::Boolean,   :'with signature'],
        [DataTypes::String,    :'public key algorithm name'],
        [DataTypes::String,    :'public key blob'],
      ]

      PUBLICKEY_SIGNATURE_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'with signature' : "TRUE"],
        [DataTypes::String,    :'signature'],
      ]

      PASSWORD_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'method name' : "password"],
        [DataTypes::Boolean,   :'FALSE'],
        [DataTypes::String,    :'plaintext password'],
      ]

      KEYBOARD_INTERACTIVE_DEFINITION = [
        #[DataTypes, Field Name]
        #[DataTypes::String,   :'method name' : "keyboard-interactive"],
        [DataTypes::String,    :'language tag'],
        [DataTypes::String,    :'submethods'],
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
