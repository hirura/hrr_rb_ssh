# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::None::Context do
  describe ".new" do
    it "takes one argument: username" do
      expect { described_class.new "username" }.not_to raise_error
    end
  end

  describe "#username" do
    let(:context_username){ "username" }
    let(:context){ described_class.new context_username }

    it "returns \"username\"" do
      expect( context.username ).to eq context_username
    end
  end

  describe "#verify" do
    let(:context_username){ "username" }
    let(:context){ described_class.new context_username }
    
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
