# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      class EncryptionAlgorithm
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

        def initialize direction, iv, key
          @logger = HrrRbSsh::Logger.new self.class.name
        end

        def block_size
          self.class::BLOCK_SIZE
        end

        def iv_length
          self.class::IV_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end
      end
    end
  end
end
