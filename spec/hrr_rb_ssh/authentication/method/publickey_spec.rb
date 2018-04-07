# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey do
  let(:name){ 'publickey' }

  it "is registered in HrrRbSsh::Authentication::Method.list" do
    expect( HrrRbSsh::Authentication::Method.list ).to include described_class
  end         

  it "can be looked up in HrrRbSsh::Authentication::Method dictionary" do
    expect( HrrRbSsh::Authentication::Method[name] ).to eq described_class
  end           

  it "appears in HrrRbSsh::Authentication::Method.name_list" do
    expect( HrrRbSsh::Authentication::Method.name_list ).to include name
  end             

  let(:session_id){ 'session id' }
  let(:authentication_publickey_authenticator){ 'authentication_publickey_authenticator' }
  let(:options){
    {
      'session id'                             => session_id,
      'authentication_publickey_authenticator' => authentication_publickey_authenticator,
    }
  }
  let(:publickey){ described_class.new(options) }

  describe ".new" do
    it "can take one argument: options" do
      expect { publickey }.not_to raise_error
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
          'public key algorithm name' => 'unsupported',
        }
      }

      it "returns false" do
        expect(publickey.authenticate userauth_request_message).to be false
      end
    end

    context "when 'public key algorithm name' is supported" do
      let(:algorithm_class){
        class AlgorithmClass
          NAME = 'supported'
        end
        AlgorithmClass
      }
      before :example do
        HrrRbSsh::Authentication::Method::Publickey::Algorithm.list.push algorithm_class
      end

      after :example do
        HrrRbSsh::Authentication::Method::Publickey::Algorithm.list.delete algorithm_class
      end

      context "when 'with signature' is false" do
        let(:userauth_request_message){
          {
            'with signature'            => false,
            'public key algorithm name' => 'supported',
            'public key blob'           => 'dummy',
          }
        }

        let(:userauth_pk_ok_message){
          {
            'message number'                             => HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
            'public key algorithm name from the request' => 'supported',
            'public key blob from the request'           => 'dummy',

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
            'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
            'user name'                 => 'username',
            'service name'              => 'ssh-connection',
            'method name'               => 'publickey',
            'with signature'            => true,
            'public key algorithm name' => 'supported',
            'public key blob'           => 'dummy',
            'signature'                 => 'signature',
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
end
