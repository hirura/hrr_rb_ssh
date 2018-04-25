# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication do
  describe '::SERVICE_NAME' do
    let(:service_name){ 'ssh-userauth' }

    it "is defined" do
      expect( described_class::SERVICE_NAME ).to eq service_name
    end
  end

  describe '#new' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:options){ Hash.new }

    it "can take one argument: transport" do
      expect { described_class.new(transport) }.not_to raise_error
    end

    it "can take two arguments: transport and options" do
      expect { described_class.new(transport, options) }.not_to raise_error
    end

    it "registeres ::SERVICE_NAME in transport" do
      expect {
        described_class.new transport
      }.to change {
        transport.instance_variable_get(:@acceptable_services)
      }.from([]).to([described_class::SERVICE_NAME])
    end
  end

  describe '#send' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }
    let(:payload){ "testing" }

    context "when transport is not closed" do
      it "sends payload" do
        expect(transport).to receive(:send).with(payload).once
        authentication.send payload
      end
    end

    context "when transport is closed" do
      it "raises ClosedAuthenticationError" do
        expect(transport).to receive(:send).with(payload).and_raise(HrrRbSsh::ClosedTransportError).once
        expect { authentication.send payload }.to raise_error HrrRbSsh::ClosedAuthenticationError
      end
    end
  end

  describe '#receive' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }
    let(:payload){ "testing" }

    context "when transport is not closed" do
      it "receives payload" do
        expect(transport).to receive(:receive).with(no_args).and_return(payload).once
        expect(authentication.receive).to eq payload
      end
    end

    context "when transport is closed" do
      it "raises ClosedAuthenticationError" do
        expect(transport).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedTransportError).once
        expect { authentication.receive }.to raise_error HrrRbSsh::ClosedAuthenticationError
      end
    end
  end

  describe '#start' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }

    it "calls transport.start and authenticate methods" do
      expect( transport ).to receive(:start).with(no_args).once
      expect( authentication ).to receive(:authenticate).with(no_args).once

      authentication.start
    end
  end

  describe '#close' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }

    context "when not closed" do
      before :example do
        authentication.instance_variable_set('@closed', false)
      end

      it "closes self" do
        authentication.close
        expect(authentication.closed?).to be true
      end

      it "calls transport.close" do
        expect(transport).to receive(:close).with(no_args).once
        authentication.close
      end
    end
  end

  describe '#closed?' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }

    context "when not closed" do
      before :example do
        authentication.instance_variable_set('@closed', false)
      end

      it "returns false" do
        expect(authentication.closed?).to be false
      end
    end

    context "when closed" do
      before :example do
        authentication.instance_variable_set('@closed', true)
      end

      it "returns true" do
        expect(authentication.closed?).to be true
      end
    end
  end

  describe '#authenticate' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, options) }
    let(:userauth_failure_message){
      {
        :'message number'                    => HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => HrrRbSsh::Authentication::Method.list_preferred,
        :'partial success'                   => false,
      }
    }
    let(:userauth_failure_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE.encode userauth_failure_message
    }
    let(:userauth_success_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS::VALUE,
      }
    }
    let(:userauth_success_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS.encode userauth_success_message
    }
    let(:username){ "username" }

    context "when accept none method" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { true },
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }

      it "sends userauth success message for none method, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(userauth_request_with_none_method_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.authenticate

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when accept password method after none method" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { false },
          'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| context.verify 'username', 'password' },
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'      => username,
          :'service name'   => "ssh-connection",
          :'method name'    => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          :'message number'     => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'          => username,
          :'service name'       => "ssh-connection",
          :'method name'        => "password",
          :'FALSE'              => false, 
          :'plaintext password' => "password"
        }
      }
      let(:userauth_request_with_password_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_password_method_message
      }
      let(:userauth_requests){
        [
          userauth_request_with_none_method_payload,
          userauth_request_with_password_method_payload,
        ]
      }

      it "sends userauth success message for password method after userauth failure message for none method, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_failure_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.authenticate

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when accept public key method with no signature, and then with sigunature" do
      let(:options){
        {
          'authentication_publickey_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| true },
        }
      }
      let(:userauth_request_with_publickey_method_with_no_signature_message){
        {
          :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'                 => username,
          :'service name'              => "ssh-connection",
          :'method name'               => "publickey",
          :'with signature'            => false, 
          :'public key algorithm name' => "ssh-rsa",
          :'public key blob'           => "dummy",
        }
      }
      let(:userauth_request_with_publickey_method_with_no_signature_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_publickey_method_with_no_signature_message
      }
      let(:userauth_request_with_publickey_method_with_signature_message){
        {
          :'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
          :'user name'                 => username,
          :'service name'              => "ssh-connection",
          :'method name'               => "publickey",
          :'with signature'            => true, 
          :'public key algorithm name' => "ssh-rsa",
          :'public key blob'           => "dummy",
          :'signature'                 => "dummy",
        }
      }
      let(:userauth_request_with_publickey_method_with_signature_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_publickey_method_with_signature_message
      }
      let(:userauth_pk_ok_message){
        {
          :'message number'                             => HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK::VALUE,
          :'public key algorithm name from the request' => "ssh-rsa",
          :'public key blob from the request'           => "dummy",
        }
      }
      let(:userauth_pk_ok_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK.encode userauth_pk_ok_message
      }
      let(:userauth_requests){
        [
          userauth_request_with_publickey_method_with_no_signature_payload,
          userauth_request_with_publickey_method_with_signature_payload,
        ]
      }

      it "sends userauth success message for publickey method with signature after userauth pk ok message for no signature message, and will return authenticated username" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_pk_ok_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.authenticate

        expect( authentication.closed? ).to be false
        expect( authentication.username ).to eq username
      end
    end

    context "when receives not userauth request" do
      let(:options){ {} }
      let(:not_userauth_request_message){
        {
          :'NOT_USERAUTH_REQUEST' => 123,
        }
      }
      let(:not_userauth_request_payload){
        [
          HrrRbSsh::DataType::Byte.encode(not_userauth_request_message.values[0]),
        ].join
      }

      it "sends userauth failure message and raise error" do
        expect( transport ).to receive(:receive).with(no_args).and_return(not_userauth_request_payload).once

        expect { authentication.authenticate }.to raise_error RuntimeError

        expect( authentication.closed? ).to be true
      end
    end
  end

  describe '#username' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }
    let(:username){ "username" }

    context "when transport is not closed" do
      before :example do
        authentication.instance_variable_set('@closed', false)
        authentication.instance_variable_set('@username', username)
      end

      it "returns authenticated username" do
        expect(authentication.username).to eq username
      end
    end

    context "when transport is closed" do
      before :example do
        authentication.instance_variable_set('@closed', true)
      end

      it "raises ClosedAuthenticationError" do
        expect { authentication.username }.to raise_error HrrRbSsh::ClosedAuthenticationError
      end
    end
  end
end
