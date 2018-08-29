# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/functionable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SshEd25519 < Algorithm
            NAME = 'ssh-ed25519'
            PREFERENCE = 60

            include Functionable
          end
        end
      end
    end
  end
end
