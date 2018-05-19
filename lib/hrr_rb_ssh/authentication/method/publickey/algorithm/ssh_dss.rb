# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/functionable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          class SshDss < Algorithm
            NAME = 'ssh-dss'
            PREFERENCE = 10
            DIGEST = 'sha1'

            include Functionable
          end
        end
      end
    end
  end
end
