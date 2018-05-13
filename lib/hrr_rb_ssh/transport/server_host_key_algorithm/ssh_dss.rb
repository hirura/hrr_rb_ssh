# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/openssl_secure_random'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshDss < ServerHostKeyAlgorithm
        NAME = 'ssh-dss'
        PREFERENCE = 10
        DIGEST = 'sha1'
        SECRET_KEY = OpenSSL::PKey::DSA.new(1024).to_pem

        def initialize secret_key=nil
          @logger = Logger.new(self.class.name)
          @dss = OpenSSL::PKey::DSA.new (secret_key || self.class::SECRET_KEY)
        end

        def server_public_host_key
          payload = {
            :'ssh-dss' => "ssh-dss",
            :'p'       => @dss.p.to_i,
            :'q'       => @dss.q.to_i,
            :'g'       => @dss.g.to_i,
            :'y'       => @dss.pub_key.to_i,
          }
          PublicKeyBlob.encode payload
        end

        def sign data
          hash = OpenSSL::Digest.digest(self.class::DIGEST, data)
          sign_der = @dss.syssign(hash)
          sign_asn1 = OpenSSL::ASN1.decode(sign_der)
          sign_r = sign_asn1.value[0].value.to_s(2).rjust(20, ["00"].pack("H"))
          sign_s = sign_asn1.value[1].value.to_s(2).rjust(20, ["00"].pack("H"))
          payload = {
            :'ssh-dss'            => "ssh-dss",
            :'dss_signature_blob' => (sign_r + sign_s),
          }
          Signature.encode payload
        end

        def verify sign, data
          payload = Signature.decode sign
          dss_signature_blob = payload[:'dss_signature_blob']
          sign_r = dss_signature_blob[ 0, 20]
          sign_s = dss_signature_blob[20, 20]
          sign_asn1 = OpenSSL::ASN1::Sequence.new(
            [
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_r, 2)),
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_s, 2)),
            ]
          )
          sign_der = sign_asn1.to_der
          hash = OpenSSL::Digest.digest(self.class::DIGEST, data)
          payload[:'ssh-dss'] == "ssh-dss" && @dss.sysverify(hash, sign_der)
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/server_host_key_algorithm/ssh_dss/public_key_blob'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/ssh_dss/signature'
