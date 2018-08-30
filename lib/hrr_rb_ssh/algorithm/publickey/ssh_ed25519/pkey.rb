# coding: utf-8
# vim: et ts=2 sw=2

require 'stringio'
require 'base64'
require 'ed25519'

module HrrRbSsh
  module Algorithm
    class Publickey
      class SshEd25519
        class PKey
          class Error < ::StandardError
          end

          def initialize arg=nil
            case arg
            when ::Ed25519::SigningKey, ::Ed25519::VerifyKey
              @key = arg
            when ::String
              @key = load_key_str arg
            when nil
              # do nothing
            end
          end

          def load_key_str key_str
            begin
              load_openssh_key key_str
            rescue
              begin
                load_openssl_key key_str
              rescue
                raise Error
              end
            end
          end

          def load_openssh_key key_str
            begin_marker = "-----BEGIN OPENSSH PRIVATE KEY-----\n"
            end_marker   = "-----END OPENSSH PRIVATE KEY-----\n"
            magic        = "openssh-key-v1"

            raise Error unless key_str.start_with? begin_marker
            raise Error unless key_str.end_with? end_marker
            decoded_key_str = Base64.decode64(key_str[begin_marker.size...-end_marker.size])
            raise Error unless decoded_key_str[0,14] == magic

            private_key_h = OpenSSHPrivateKey.decode decoded_key_str[15..-1]
            private_key_content_h = OpenSSHPrivateKeyContent.decode private_key_h[:'content']
            key_pair = private_key_content_h[:'key pair']

            ::Ed25519::SigningKey.new(key_pair[0,32])
          end

          def load_openssl_key key_str
            private_key_begin_marker = "-----BEGIN PRIVATE KEY-----\n"
            public_key_begin_marker  = "-----BEGIN PUBLIC KEY-----\n"
            if key_str.start_with? private_key_begin_marker
              begin_marker = "-----BEGIN PRIVATE KEY-----\n"
              end_marker   = "-----END PRIVATE KEY-----\n"

              raise Error unless key_str.start_with? begin_marker
              raise Error unless key_str.end_with? end_marker

              decoded_key_str = Base64.decode64(key_str[begin_marker.size...-end_marker.size])
              key_der = OpenSSL::ASN1.decode decoded_key_str

              ::Ed25519::SigningKey.new(key_der.value[2].value[2..-1])
            elsif key_str.start_with? public_key_begin_marker
              begin_marker = "-----BEGIN PUBLIC KEY-----\n"
              end_marker   = "-----END PUBLIC KEY-----\n"

              raise Error unless key_str.start_with? begin_marker
              raise Error unless key_str.end_with? end_marker

              decoded_key_str = Base64.decode64(key_str[begin_marker.size...-end_marker.size])
              key_der = OpenSSL::ASN1.decode decoded_key_str

              ::Ed25519::VerifyKey.new(key_der.value[1].value)
            else
              raise Error
            end
          end

          def set_public_key key_str
            @key = ::Ed25519::VerifyKey.new(key_str)
          end

          def to_pem
            ed25519_object_id = '1.3.101.112'
            case @key
=begin
            when ::Ed25519::SigningKey
              begin_marker = "-----BEGIN PRIVATE KEY-----\n"
              end_marker   = "-----END PRIVATE KEY-----\n"
              key_asn1 = OpenSSL::ASN1::Sequence.new(
                [
                  OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(0)),
                  OpenSSL::ASN1::Sequence.new(
                    [
                      OpenSSL::ASN1::ObjectId.new(ed25519_object_id),
                    ]
                  ),
                  OpenSSL::ASN1::OctetString.new(@key.to_bytes),
                ]
              )
=end
            when ::Ed25519::VerifyKey
              begin_marker = "-----BEGIN PUBLIC KEY-----\n"
              end_marker   = "-----END PUBLIC KEY-----\n"
              key_asn1 = OpenSSL::ASN1::Sequence.new(
                [
                  OpenSSL::ASN1::Sequence.new(
                    [
                      OpenSSL::ASN1::ObjectId.new(ed25519_object_id),
                    ]
                  ),
                  OpenSSL::ASN1::BitString.new(@key.to_bytes),
                ]
              )
            end
            pem_str = Base64.encode64(key_asn1.to_der)
            begin_marker + pem_str + end_marker
          end

          def public_key
            case @key
            when ::Ed25519::SigningKey
              self.class.new @key.verify_key
            when ::Ed25519::VerifyKey
              self
            end
          end

          def key_str
            @key.to_bytes
          end

          def sign data
            @key.sign data
          end

          def verify signature, data
            begin
              @key.verify signature, data
            rescue ::Ed25519::VerifyError
              false
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/openssh_private_key'
require 'hrr_rb_ssh/algorithm/publickey/ssh_ed25519/openssh_private_key_content'
