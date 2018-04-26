# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class EcdsaSha2Nistp256
        module PublicKeyBlob
          class << self
            include Codable
          end
          DEFINITION = [
            [DataType::String, :'ecdsa-sha2-[identifier]'],
            [DataType::String, :'[identifier]'],
            [DataType::String, :'Q'],
          ]
        end
      end
    end
  end
end

