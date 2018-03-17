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

    it "sends payload" do
      expect(transport).to receive(:send).with(payload).once
      authentication.send payload
    end
  end

  describe '#receive' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport) }
    let(:payload){ "testing" }

    it "receives payload" do
      expect(transport).to receive(:receive).with(no_args).and_return(payload).once
      expect(authentication.receive).to eq payload
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

  describe '#authenticate' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ described_class.new(transport, options) }
    let(:userauth_failure_message){
      {
        "SSH_MSG_USERAUTH_FAILURE"          => 51,
        'authentications that can continue' => HrrRbSsh::Authentication::Method.name_list,
        'partial success'                   => false,
      }
    }
    let(:userauth_failure_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE.encode userauth_failure_message
    }
    let(:userauth_success_message){
      {
        "SSH_MSG_USERAUTH_SUCCESS" => 52,
      }
    }
    let(:userauth_success_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS.encode userauth_success_message
    }

    context "when accept none method" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { true },
        }
      }
      let(:userauth_request_with_none_method_message){
        {
          "SSH_MSG_USERAUTH_REQUEST" => 50,
          "user name"                => "username",
          "service name"             => "ssh-connection",
          "method name"              => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }

      it "receives" do
        expect( transport ).to receive(:receive).with(no_args).and_return(userauth_request_with_none_method_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.authenticate
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
          "SSH_MSG_USERAUTH_REQUEST" => 50,
          "user name"                => "username",
          "service name"             => "ssh-connection",
          "method name"              => "none",
        }
      }
      let(:userauth_request_with_none_method_payload){
        HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
      }
      let(:userauth_request_with_password_method_message){
        {
          "SSH_MSG_USERAUTH_REQUEST" => 50,
          "user name"                => "username",
          "service name"             => "ssh-connection",
          "method name"              => "password",
          "FALSE"                    => false, 
          "plaintext password"       => "password"
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

      it "receives" do
        expect( transport ).to receive(:receive).with(no_args).and_return(*userauth_requests).twice
        expect( transport ).to receive(:send).with(userauth_failure_payload).once
        expect( transport ).to receive(:send).with(userauth_success_payload).once

        authentication.authenticate
      end
    end

    context "when receives not userauth request" do
      let(:options){ {} }
      let(:not_userauth_request_message){
        {
          "NOT_USERAUTH_REQUEST" => 123,
        }
      }
      let(:not_userauth_request_payload){
        [
          HrrRbSsh::Transport::DataType::Byte.encode(not_userauth_request_message.values[0]),
        ].join
      }

      it "receives" do
        expect( transport ).to receive(:receive).with(no_args).and_return(not_userauth_request_payload).once

        expect { authentication.authenticate }.to raise_error RuntimeError
      end
    end
  end
end
