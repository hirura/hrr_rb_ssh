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
          public_key_blob = Authentication::Method::Publickey::Algorithm[@algorithm_name]::PublicKeyBlob.decode Base64.decode64(splitted[1])
          case @algorithm_name
          when 'ssh-dss'
            @algorithm = OpenSSL::PKey::DSA.new
            if @algorithm.respond_to?(:set_pqg)
              @algorithm.set_pqg public_key_blob[:'p'], public_key_blob[:'q'], public_key_blob[:'g']
            else
              @algorithm.p = public_key_blob[:'p']
              @algorithm.q = public_key_blob[:'q']
              @algorithm.g = public_key_blob[:'g']
            end
            if @algorithm.respond_to?(:set_key)
              @algorithm.set_key public_key_blob[:'y'], nil
            else
              @algorithm.pub_key = public_key_blob[:'y']
            end
            @pem = @algorithm.public_key.to_pem
          when 'ssh-rsa'
            @algorithm = OpenSSL::PKey::RSA.new
            if @algorithm.respond_to?(:set_key)
              @algorithm.set_key public_key_blob[:'n'], public_key_blob[:'e'], nil
            else
              @algorithm.e = public_key_blob[:'e']
              @algorithm.n = public_key_blob[:'n']
            end
            @pem = @algorithm.public_key.to_pem
          when 'ecdsa-sha2-nistp256'
            @algorithm = OpenSSL::PKey::EC.new('prime256v1')
            @algorithm.public_key = OpenSSL::PKey::EC::Point.new(@algorithm.group, OpenSSL::BN.new(public_key_blob[:'Q'], 2))
            @pem = @algorithm.to_pem
          when 'ecdsa-sha2-nistp384'
            @algorithm = OpenSSL::PKey::EC.new('secp384r1')
            @algorithm.public_key = OpenSSL::PKey::EC::Point.new(@algorithm.group, OpenSSL::BN.new(public_key_blob[:'Q'], 2))
            @pem = @algorithm.to_pem
          when 'ecdsa-sha2-nistp521'
            @algorithm = OpenSSL::PKey::EC.new('secp521r1')
            @algorithm.public_key = OpenSSL::PKey::EC::Point.new(@algorithm.group, OpenSSL::BN.new(public_key_blob[:'Q'], 2))
            @pem = @algorithm.to_pem
          end
        end

        def algorithm_name
          @algorithm_name
        end

        def to_pem
          @pem
        end
      end
    end
  end
end
