# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Password do
  let(:name){ 'password' }
  let(:transport){ 'dummy' }

  it "can be looked up in HrrRbSsh::Authentication::Method dictionary" do
    expect( HrrRbSsh::Authentication::Method[name] ).to eq described_class
  end                              

  it "is registered in HrrRbSsh::Authentication::Method.list_supported" do
    expect( HrrRbSsh::Authentication::Method.list_supported ).to include name
  end         

  it "appears in HrrRbSsh::Authentication::Method.list_preferred" do
    expect( HrrRbSsh::Authentication::Method.list_preferred ).to include name
  end           

  describe ".new" do
    it "takes three arguments: transport, options, and variables" do
      expect { described_class.new(transport, {}, {}) }.not_to raise_error
    end     
  end

  describe "#authenticate" do
    let(:variables){ {} }
    let(:userauth_request_message){
      {
        :'user name'          => "username",
        :'plaintext password' => "password",
      }
    }

    context "when options does not have 'authentication_password_authenticator'" do
      let(:options){ {} }
      let(:password_method){ described_class.new transport, options, variables }

      it "returns false" do
        expect( password_method.authenticate userauth_request_message ).to be false
      end
    end

    context "when options has 'authentication_password_authenticator' and it returns true" do
      let(:options){
        {
          'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { true }
        }
      }
      let(:password_method){ described_class.new transport, options, variables }

      it "returns true" do
        expect( password_method.authenticate userauth_request_message ).to be true
      end
    end

    context "when options has 'authentication_password_authenticator' and it verifies 'username' and 'password'" do
      context "with \"username\" and \"password\"" do
        let(:options){
          {
            'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| context.verify "username", "password" }
          }
        }
        let(:password_method){ described_class.new transport, options, variables }

        it "returns true" do
          expect( password_method.authenticate userauth_request_message ).to be true
        end
      end

      context "with \"mismatch\" and \"mismatch\"" do
        let(:options){
          {
            'authentication_password_authenticator' => HrrRbSsh::Authentication::Authenticator.new { |context| context.verify "mismatch", "mismatch" }
          }
        }
        let(:password_method){ described_class.new transport, options, variables }

        it "returns false" do
          expect( password_method.authenticate userauth_request_message ).to be false
        end
      end
    end
  end
end
