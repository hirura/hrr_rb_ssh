# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/functionable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class EcdsaSha2Nistp384 < Algorithm
            NAME = 'ecdsa-sha2-nistp384'
            PREFERENCE = 40

            include Functionable
          end
        end
      end
    end
  end
end
