# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::KeyboardInteractive::Context do
  let(:context_transport){ double('transport') }
  let(:context_username){ "username" }
  let(:context_submethods){ "submethods" }
  let(:context){ described_class.new context_transport, context_username, context_submethods }

  describe ".new" do
    it "takes three arguments: transport, username and submethods" do
      expect { context }.not_to raise_error
    end
  end

  describe "#username" do
    it "returns \"username\"" do
      expect( context.username ).to eq context_username
    end
  end

  describe "#submethods" do
    it "returns \"submethods\"" do
      expect( context.submethods ).to eq context_submethods
    end
  end

  describe "#info_response" do
    context "before calling #info_request" do
      it "returns nil" do
        expect( context.info_response ).to be nil
      end
    end
  end
end
