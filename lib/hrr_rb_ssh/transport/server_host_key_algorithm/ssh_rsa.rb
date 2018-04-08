# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/transport/server_host_key_algorithm/server_host_key_algorithm'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      class SshRsa < ServerHostKeyAlgorithm
        NAME = 'ssh-rsa'

        SECRET_KEY = <<-EOB
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA71zHt9RvbXmxuOCWPKR65iBHO+a8M7Mfo4vRCs/dorZN7XL1
lYwjclvo0X1T39BRX+qJ2m4HB+7Vlef9YF7spYKm6czuSCYmJjD5X+PW5QYSGED1
fFSXwjTdDwJi1OKS4kL0Dd6zcSjlFxfjVLNCyUcix36XgDpoBLBFkDZd5P2ow3J6
WNanBasXrckjCk4M3kFclvmxl1O56bbV9VZq51ZqLjv/ZhOrE3WIPfrJGdZssODa
DnI6tM1puwZGVba9VaI8FfnuJcacJ3T9oEoXPY5W+kPZAw6dOARXnJTg+oZk/dBD
Bgej0aMO+1XM7HKz5BiqbhGGSXGas5zoefHbNwIDAQABAoIBAQDP2aQ/2EOuL8eI
/9TV8goafRr+RB1XU4r8zHOIzPnryhyfPX1OEDPToUXpa8gCiPWwsYxlVbfbRqTH
mHzoS2V5T5u7WE3t7tqfvVU+1C0OERhzYS0KeraRWLBA0VSbAeiEe5lL1f/CGr3c
MM0iBsvO1mu4ChBqs80RjTPKx7r/FStpWtqWN4kn+Bhj06qCqhftnudZdYFTHa/G
ia4YWOUH6dSIZKpE7oG53Gm/2ZdK2YiAgMOdrTQkvRzxuIa/RHaETj21hKpetmI7
TfS26RbU2t1Bf/fdFhtTqoAz+CrZEH7Z407ZO45fdc31zJAFIK2Zf3CDVnKwih3t
O0bEVSSpAoGBAP/zEWaTivdQtcemMRhFQBySgnStov+dsxnGBnTkWxVIU7VoFgyg
mgNRlWUxMf12mlfqBVRpx0/ALggHf5KFmbAZ+3qvKSLmfIVM5E9l5NKbZnCWtIqq
1DN9kHPPOZn3uYvOs9Cpn7S6sa+rVZ82Mg8EZMsPesvFMOjrgNbMQxt7AoGBAO9o
38VM0+M09sAgOhmqv+Esa2gUGw5n18o/fdmlZdnA+D2ntgr70AD6JUCSYrZgTJRq
HNMuKrbD6HyaPjVaxYJVCFJIcfV+nViZdE8cHh9WXQ/JP/T6nvNajCC8StvoQg4I
vAZFTzChoe2yrOsWXezn9QAecQ8L2WHDLImpayR1AoGADoc1jaUCVld2egas8ru7
j+OhFA5nGitRZz0eULRFl0eruLhXyA+1rkqLOFs6gzCgQi0+cDQw5A38jugeDasX
ti9DXwtiQmDi4I4kx3z5KBs6DVoAlX5s3R9be7dfhaXSGmV5P3bhYdjXDSmkio0A
+mk9b2lJhxeCVzZG8epWRNECgYB2KzGoVQ+Q6ieRFVcYLCuhnSc2rBXeumrMrSIV
N4paPOFKrWkxarF0igOxJ5AJrOafqvCnW/ZBV9l9BzUFaNRsTERbON7m6aQIg1Xh
ZmOH3Dz6+b7T0JB8VYks70OT38Qa4TzNa5B21JD0nmizcMrTkHphoKT1ZEfb9VYa
bMExsQKBgQDoSpo/ZP8+dwR1A/gcu2K5Ie47c3WgKw7qQMarxqzTeS8Xu6/KAn+J
Ka2zIvoHhxlhXFBRhp+FIaFlYRR38gHeNxCoUylpboCUyMkHOsOP43AiKsmbNK20
vzTNM3SFzgt3bHkdEtDLc64aoBX+dHOot6u71XLZrshnHPtiZ0C/ZA==
-----END RSA PRIVATE KEY-----
        EOB

        KEY_FORMAT_DEFINITION = [
          [DataType::String, 'ssh-rsa'],
          [DataType::Mpint,  'e'],
          [DataType::Mpint,  'n'],
        ]

        SIGN_DEFINITION = [
          [DataType::String, 'ssh-rsa'],
          [DataType::String, 'rsa_signature_blob'],
        ]

        def initialize
          super

          @rsa = OpenSSL::PKey::RSA.new SECRET_KEY
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
            'ssh-rsa' => 'ssh-rsa',
            'e'       => @rsa.e.to_i,
            'n'       => @rsa.n.to_i,
          }
          encode KEY_FORMAT_DEFINITION, payload
        end

        def sign digest, data
          payload = {
            'ssh-rsa'            => 'ssh-rsa',
            'rsa_signature_blob' => @rsa.sign(digest, data),
          }
          encode SIGN_DEFINITION, payload
        end

        def verify digest, sign, data
          payload = decode SIGN_DEFINITION, sign
          payload['ssh-rsa'] == 'ssh-rsa' && @rsa.verify(digest, payload['rsa_signature_blob'], data)
        end
      end
    end
  end
end
