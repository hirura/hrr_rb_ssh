# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::None::Context do
  let(:context_username){ 'username' }
  let(:context_variables){ {} }
  let(:context_authentication_methods){ [] }
  let(:context){ described_class.new context_username, context_variables, context_authentication_methods }

  describe ".new" do
    it "takes one argument: username" do
      expect { context }.not_to raise_error
    end
  end

  describe "#username" do
    let(:context_username){ "username" }
    let(:context){ described_class.new context_username, context_variables, context_authentication_methods }

    it "returns \"username\"" do
      expect( context.username ).to eq context_username
    end
  end

  describe "#variables" do
    it "returns \"variables\"" do
      expect( context.variables ).to be context_variables
    end
  end

  describe "#vars" do
    it "returns \"variables\"" do
      expect( context.vars ).to be context_variables
    end
  end

  describe "#authentication_methods" do
    it "returns \"authentication_methods\"" do
      expect( context.authentication_methods ).to be context_authentication_methods
    end
  end

  describe "#verify" do
    let(:context_username){ "username" }
    let(:context){ described_class.new context_username, context_variables, context_authentication_methods }

    context "with \"username\"" do
      let(:username){ "username" }

      it "returns true" do
        expect( context.verify username ).to be true
      end
    end

    context "with \"mismatch\"" do
      let(:username){ "mismatch" }

      it "returns false" do
        expect( context.verify username ).to be false
      end
    end
  end
end
