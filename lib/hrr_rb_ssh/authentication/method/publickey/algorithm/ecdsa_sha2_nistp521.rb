require 'hrr_rb_ssh/authentication/method/publickey/algorithm/functionable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class EcdsaSha2Nistp521 < Algorithm
            NAME = 'ecdsa-sha2-nistp521'
            PREFERENCE = 50

            include Functionable
          end
        end
      end
    end
  end
end
