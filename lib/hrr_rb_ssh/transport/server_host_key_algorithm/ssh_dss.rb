# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshDss < ServerHostKeyAlgorithm
        NAME = 'ssh-dss'

        PREFERENCE = 10

        SECRET_KEY = <<-EOB
-----BEGIN DSA PRIVATE KEY-----
MIIBuwIBAAKBgQD3fQ6cwTtOJpVI0iASOQZxkhwPRNy7UwovQkEK6bXW33HaCebO
PnNiY/rR4uFhjvHRzF8KnC8xk3fNo4ZJQJlaEHv6qySiXHeX1fw/eo/uzM5WafLd
oaRtE2muky1i3FBCiboXDlNcwuA/efsOE5qsGBbk6svw+8pGolHmOZFSvQIVAN2G
ZxtE9Kqqh6z48/VulQZsrh5hAoGAH3191okH8kUwP3dinp5j5YtNzrJ20sBXNNZG
0aWjtS2xjSjIXjnlkiwhhvcUcCEkUQ507exvSLgf4dyV/V4+nf5Q5zjLztiSMe9D
qhTRIR23lsDu0OdITQihTu+Y4GEvNLUL9r2P1aoF/sde97xzzqmXPKx0UL1nNzcL
dnAdjjMCgYAa1dRvXe65jufPk0kRwhewRSScfg+YK4DOLUYGalsjHZbXtXqHKNpB
YkTlWKMg6QVREN0+5aNY1z1aJAbNboLz55YBnS9tOBYzvsXQF7ZP1ECMO6m4I8DI
wxt35i8hEVOJc+8x/xtmogzbjepar+1UycJQTMjhvqCW7RF4LuepvwIVANELTvnl
MRl/p42OrQzL/chRPvRf
-----END DSA PRIVATE KEY-----
        EOB

        KEY_FORMAT_DEFINITION = [
          [DataType::String, 'ssh-dss'],
          [DataType::Mpint,  'p'],
          [DataType::Mpint,  'q'],
          [DataType::Mpint,  'g'],
          [DataType::Mpint,  'y'],
        ]

        SIGN_DEFINITION = [
          [DataType::String, 'ssh-dss'],
          [DataType::String, 'dss_signature_blob'],
        ]

        def initialize
          @logger = HrrRbSsh::Logger.new(self.class.name)
          @dss = OpenSSL::PKey::DSA.new SECRET_KEY
        end

        def encode definition, payload
          definition.map{ |data_type, field_name|
            field_value = if payload[field_name].instance_of? ::Proc then payload[field_name].call else payload[field_name] end
            data_type.encode( field_value )
          }.join
        end

        def decode definition, payload
          payload_io = StringIO.new payload, 'r'
          definition.map{ |data_type, field_name|
            [
              field_name,
              data_type.decode( payload_io )
            ]
          }.to_h
        end

        def server_public_host_key
          payload = {
            'ssh-dss' => 'ssh-dss',
            'p'       => @dss.p.to_i,
            'q'       => @dss.q.to_i,
            'g'       => @dss.g.to_i,
            'y'       => @dss.pub_key.to_i,
          }
          encode KEY_FORMAT_DEFINITION, payload
        end

        def sign digest, data
          hash = OpenSSL::Digest.digest(digest, data)
          sign_der = @dss.syssign(hash)
          sign_asn1 = OpenSSL::ASN1.decode(sign_der)
          sign_r = sign_asn1.value[0].value.to_s(2).rjust(20, ["00"].pack("H"))
          sign_s = sign_asn1.value[1].value.to_s(2).rjust(20, ["00"].pack("H"))
          payload = {
            'ssh-dss'            => 'ssh-dss',
            'dss_signature_blob' => (sign_r + sign_s),
          }
          encode SIGN_DEFINITION, payload
        end

        def verify digest, sign, data
          payload = decode SIGN_DEFINITION, sign
          dss_signature_blob = payload['dss_signature_blob']
          sign_r = dss_signature_blob[ 0, 20]
          sign_s = dss_signature_blob[20, 20]
          sign_asn1 = OpenSSL::ASN1::Sequence.new(
            [
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_r, 2)),
              OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(sign_s, 2)),
            ]
          )
          sign_der = sign_asn1.to_der
          hash = OpenSSL::Digest.digest(digest, data)
          payload['ssh-dss'] == 'ssh-dss' && @dss.sysverify(hash, sign_der)
        end
      end
    end
  end
end
