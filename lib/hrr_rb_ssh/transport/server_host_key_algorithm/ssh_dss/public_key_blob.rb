# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/codable'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshDss
        module PublicKeyBlob
          class << self
            include Codable
          end
          DEFINITION = [
            [DataType::String, 'ssh-dss'],
            [DataType::Mpint,  'p'],
            [DataType::Mpint,  'q'],
            [DataType::Mpint,  'g'],
            [DataType::Mpint,  'y'],
          ]
        end
      end
    end
  end
end
