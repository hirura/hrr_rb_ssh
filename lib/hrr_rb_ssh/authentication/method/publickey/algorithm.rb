# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    class Method
      class Publickey
        module Algorithm
          def self.list
            Algorithm.list
          end

          def self.name_list
            Algorithm.name_list
          end

          def self.[] key
            Algorithm[key]
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/publickey/algorithm/algorithm'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_dss'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/ssh_rsa'
