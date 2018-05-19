# coding: utf-8
# vim: et ts=2 sw=2

require 'base64'
require 'openssl'

module HrrRbSsh
  module Compat
    module OpenSSH
      class PublicKey
        def initialize data_line
          splitted = data_line.split(' ')
          @algorithm_name = splitted[0]
          public_key_blob = Base64.decode64(splitted[1])
          @publickey = Algorithm::Publickey[@algorithm_name].new public_key_blob
        end

        def algorithm_name
          @algorithm_name
        end

        def to_pem
          @publickey.to_pem
        end
      end
    end
  end
end
