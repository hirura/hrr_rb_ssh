# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/authentication/method/publickey/algorithm/codable'

module HrrRbSsh
  class Authentication
    module Method
      class Publickey
        module Algorithm
          class Algorithm
            @@list = Array.new

            def self.inherited klass
              @@list.push klass
            end

            def self.list
              @@list
            end

            def self.name_list
              @@list.map{ |klass| klass::NAME }
            end

            def self.[] key
              @@list.find{ |klass| key == klass::NAME }
            end

            def initialize
              @logger = HrrRbSsh::Logger.new self.class.name
            end

            include Codable
          end
        end
      end
    end
  end
end
