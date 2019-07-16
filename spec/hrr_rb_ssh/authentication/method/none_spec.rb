# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::None do
  let(:name){ 'none' }
  let(:transport){ double('transport') }

  it "can be looked up in HrrRbSsh::Authentication::Method dictionary" do
    expect( HrrRbSsh::Authentication::Method[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Authentication::Method.list_supported" do
    expect( HrrRbSsh::Authentication::Method.list_supported ).to include name
  end

  it "appears in HrrRbSsh::Authentication::Method.list_preferred" do
    expect( HrrRbSsh::Authentication::Method.list_preferred ).not_to include name
  end

  describe ".new" do
    it "takes three arguments: transport, options, variables, and authentication_methods" do
      expect { described_class.new(transport, {}, {}, []) }.not_to raise_error
    end
  end

  describe "#authenticate" do
    let(:variables){ {} }
    let(:authentication_methods){ [] }
    let(:userauth_request_message){
      {
        :'user name' => "username",
      }
    }

    context "when options does not have 'authentication_none_authenticator'" do
      let(:options){ {} }
      let(:none_method){ described_class.new transport, options, variables, authentication_methods }

      it "returns false" do
        expect( none_method.authenticate userauth_request_message ).to be false
      end
    end

    context "when options has 'authentication_none_authenticator' and it returns true" do
      let(:options){
        {
          'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { true }
        }
      }
      let(:none_method){ described_class.new transport, options, variables, authentication_methods }

      it "returns true" do
        expect( none_method.authenticate userauth_request_message ).to be true
      end
    end

    context "when options has 'authentication_none_authenticator' and it verifies 'username'" do
      context "with \"username\"" do
        let(:options){
          {
            'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| context.verify "username" }
          }
        }
        let(:none_method){ described_class.new transport, options, variables, authentication_methods }

        it "returns true" do
          expect( none_method.authenticate userauth_request_message ).to be true
        end
      end

      context "with \"mismatch\"" do
        let(:options){
          {
            'authentication_none_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| context.verify "mismatch" }
          }
        }
        let(:none_method){ described_class.new transport, options, variables, authentication_methods }

        it "returns false" do
          expect( none_method.authenticate userauth_request_message ).to be false
        end
      end
    end
  end

  describe "#request_authentication" do
    let(:options){ {} }
    let(:none_method){ described_class.new transport, options, {}, [] }
    let(:username){ "username" }
    let(:service_name){ "ssh-connection" }
    let(:userauth_request_with_none_method_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
        :'user name'      => username,
        :'service name'   => service_name,
        :'method name'    => "none",
      }
    }
    let(:userauth_request_with_none_method_payload){
      HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.encode userauth_request_with_none_method_message
    }

    it "sends userauth request for none method" do
      expect( transport ).to receive(:send).with(userauth_request_with_none_method_payload).once
      expect( transport ).to receive(:receive).with(no_args).and_return("payload").once

      expect( none_method.request_authentication username, service_name ).to eq "payload"
    end
  end
end
