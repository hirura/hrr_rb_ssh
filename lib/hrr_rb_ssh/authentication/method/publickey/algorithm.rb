# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_with_preference_listable'

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        class Algorithm
          @subclass_list = Array.new
          class << self
            include SubclassWithPreferenceListable
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_dss'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_rsa'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp256'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp384'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ecdsa_sha2_nistp521'
