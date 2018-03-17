# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::None do
  describe ".new" do
    it "can take one argument: options" do
      expect { described_class.new({}) }.not_to raise_error
    end
  end

  describe "#authenticate" do
    let(:userauth_request_message){
      {
        'user name' => 'username',
      }
    }

    context "when options does not have 'authentication_none_authenticator'" do
      let(:options){ {} }
      let(:none_method){ described_class.new options }
    
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
      let(:none_method){ described_class.new options }
    
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
        let(:none_method){ described_class.new options }

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
        let(:none_method){ described_class.new options }

        it "returns false" do
          expect( none_method.authenticate userauth_request_message ).to be false
        end
      end
    end
  end
end
