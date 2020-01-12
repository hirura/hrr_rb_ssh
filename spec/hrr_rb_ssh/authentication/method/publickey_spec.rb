# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey do
  let(:name){ 'publickey' }
  let(:transport){ double('transport') }

  it "can be looked up in HrrRbSsh::Authentication::Method dictionary" do
    expect( HrrRbSsh::Authentication::Method[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Authentication::Method.list_supported" do
    expect( HrrRbSsh::Authentication::Method.list_supported ).to include name
  end

  it "appears in HrrRbSsh::Authentication::Method.list_preferred" do
    expect( HrrRbSsh::Authentication::Method.list_preferred ).to include name
  end

  let(:session_id){ 'session id' }
  let(:authentication_publickey_authenticator){ 'authentication_publickey_authenticator' }
  let(:options){
    {
      'session id'                             => session_id,
      'authentication_publickey_authenticator' => authentication_publickey_authenticator,
    }
  }
  let(:variables){ {} }
  let(:authentication_methods){ [] }
  let(:publickey){ described_class.new(transport, options, variables, authentication_methods) }

  describe ".new" do
    it "takes three arguments: transport, options, variables, and authentication_methods" do
      expect { described_class.new(transport, {}, {}, []) }.not_to raise_error
    end

    it "stores @session_id" do
      expect(publickey.instance_variable_get('@session_id')).to be session_id
    end

    it "stores @authenticator" do
      expect(publickey.instance_variable_get('@authenticator')).to be authentication_publickey_authenticator
    end
  end

  describe "#authenticate" do
    context "when 'public key algorithm name' is unsupported" do
      let(:userauth_request_message){
        {
          :'public key algorithm name' => "unsupported",
        }
      }

      it "returns false" do
        expect(publickey.authenticate userauth_request_message).to be false
      end
    end

    context "when 'public key algorithm name' is supported" do
      let(:algorithm_class){
        Class.new do
          const_set(:NAME, 'supported')
          const_set(:PREFERENCE, 100)
          include HrrRbSsh::Authentication::Method::Publickey::Algorithm::Functionable
        end
      }
      before :example do
        HrrRbSsh::Authentication::Method::Publickey::Algorithm.instance_variable_get('@subclass_list').push algorithm_class
      end

      after :example do
        HrrRbSsh::Authentication::Method::Publickey::Algorithm.instance_variable_get('@subclass_list').delete algorithm_class
      end

      context "when 'with signature' is false" do
        let(:userauth_request_message){
          {
            :'with signature'            => false,
            :'public key algorithm name' => "supported",
            :'public key blob'           => "dummy",
          }
        }

        let(:userauth_pk_ok_message){
          {
            :'message number'                             => HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
            :'public key algorithm name from the request' => "supported",
            :'public key blob from the request'           => "dummy",
          }
        }
        let(:userauth_pk_ok_payload){
          HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK.encode userauth_pk_ok_message
        }

        it "returns userauth_pk_ok payload" do
          expect(publickey.authenticate userauth_request_message).to eq userauth_pk_ok_payload
        end
      end

      context "when 'with signature' is true" do
        let(:userauth_request_message){
          {
            :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
            :'user name'                 => "username",
            :'service name'              => "ssh-connection",
            :'method name'               => "publickey",
            :'with signature'            => true,
            :'public key algorithm name' => "supported",
            :'public key blob'           => "dummy",
            :'signature'                 => "signature",
          }
        }

        context "when options does not have 'authentication_publickey_authenticator'" do
          let(:options){
            {
              'session id' => session_id,
            }
          }

          it "returns false" do
            allow(HrrRbSsh::Authentication::Method::Publickey::Context).to receive(:new).with(any_args).and_return(nil).once
            expect( publickey.authenticate userauth_request_message ).to be false
          end
        end

        context "when options does not have 'authentication_publickey_authenticator'" do
          let(:authentication_publickey_authenticator){ HrrRbSsh::Authentication::Authenticator.new { true } }

          it "returns true" do
            allow(HrrRbSsh::Authentication::Method::Publickey::Context).to receive(:new).with(any_args).and_return(nil).once
            expect( publickey.authenticate userauth_request_message ).to be true
          end
        end

        context "when options has 'authentication_publickey_authenticator' and it verifies as expected" do
          let(:authentication_publickey_authenticator){
            HrrRbSsh::Authentication::Authenticator.new { |context|
              [
                (context.instance_variable_get('@username')                  == 'username'),
                (context.instance_variable_get('@algorithm').class           == algorithm_class),
                (context.instance_variable_get('@session_id')                == session_id),
                (context.instance_variable_get('@message')                   == userauth_request_message),
                (context.instance_variable_get('@message_number')            == HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE),
                (context.instance_variable_get('@service_name')              == 'ssh-connection'),
                (context.instance_variable_get('@method_name')               == 'publickey'),
                (context.instance_variable_get('@with_signature')            == true),
                (context.instance_variable_get('@public_key_algorithm_name') == 'supported'),
                (context.instance_variable_get('@public_key_blob')           == 'dummy'),
                (context.instance_variable_get('@signature')                 == 'signature'),
              ].all?
            }
          }

          it "returns true" do
            expect( publickey.authenticate userauth_request_message ).to be true
          end
        end
      end
    end
  end

  describe "#request_authentication" do
    let(:options){
      {
        'session id' => session_id,
        'client_authentication_publickey' => [
          "ssh-rsa",
          <<-'EOB'
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
        ]
      }
    }
    let(:publickey_method){ described_class.new transport, options, {}, [] }
    let(:session_id){ '1' }
    let(:username){ "username" }
    let(:service_name){ "ssh-connection" }
    let(:public_key_blob){
      algorithm = HrrRbSsh::Authentication::Method::Publickey::Algorithm[options['client_authentication_publickey'][0]].new
      algorithm.generate_public_key_blob(options['client_authentication_publickey'][1])
    }
    let(:signature){
      algorithm = HrrRbSsh::Authentication::Method::Publickey::Algorithm[options['client_authentication_publickey'][0]].new
      algorithm.generate_signature(session_id, username, service_name, 'publickey', options['client_authentication_publickey'][1])
    }
    let(:userauth_request_with_publickey_method_without_signature_message){
      {
        :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
        :'user name'                 => username,
        :'service name'              => service_name,
        :'method name'               => "publickey",
        :'with signature'            => false,
        :'public key algorithm name' => "ssh-rsa",
        :'public key blob'           => public_key_blob,
      }
    }
    let(:userauth_request_with_publickey_method_without_signature_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_publickey_method_without_signature_message
    }
    let(:userauth_request_with_publickey_method_with_signature_message){
      {
        :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
        :'user name'                 => username,
        :'service name'              => service_name,
        :'method name'               => "publickey",
        :'with signature'            => true,
        :'public key algorithm name' => "ssh-rsa",
        :'public key blob'           => public_key_blob,
        :'signature'                 => signature,
      }
    }
    let(:userauth_request_with_publickey_method_with_signature_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_publickey_method_with_signature_message
    }

    context "when response for with signature false message is pk_ok" do
      let(:userauth_pk_ok_message){
        {
          :'message number'                             => HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
          :'public key algorithm name from the request' => "ssh-rsa",
          :'public key blob from the request'           => public_key_blob,
        }
      }
      let(:userauth_pk_ok_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK.encode userauth_pk_ok_message
      }

      it "sends userauth request for publickey method" do
        expect( transport ).to receive(:send).with(userauth_request_with_publickey_method_without_signature_payload).once
        expect( transport ).to receive(:send).with(userauth_request_with_publickey_method_with_signature_payload).once
        expect( transport ).to receive(:receive).with(no_args).and_return(userauth_pk_ok_payload, "payload").twice

        expect( publickey_method.request_authentication username, service_name ).to eq "payload"
      end
    end

    context "when response for with signature false message is other than pk_ok" do
      it "sends userauth request for publickey method" do
        expect( transport ).to receive(:send).with(userauth_request_with_publickey_method_without_signature_payload).once
        expect( transport ).to receive(:receive).with(no_args).and_return("payload").once

        expect( publickey_method.request_authentication username, service_name ).to eq "payload"
      end
    end
  end
end
