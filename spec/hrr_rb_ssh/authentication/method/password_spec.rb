# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Password do
  describe ".new" do
    it "can take one argument: options" do
      expect { described_class.new({}) }.not_to raise_error
    end
  end

  describe "#authenticate" do
    let(:userauth_request_message){
      {
        'user name'          => 'username',
        'plaintext password' => 'password',
      }
    }

    context "when options does not have 'authentication_password_authenticator'" do
      let(:options){ {} }
      let(:password_method){ described_class.new options }
    
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
      let(:password_method){ described_class.new options }
    
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
        let(:password_method){ described_class.new options }

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
        let(:password_method){ described_class.new options }

        it "returns false" do
          expect( password_method.authenticate userauth_request_message ).to be false
        end
      end
    end
  end
end
