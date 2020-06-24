RSpec.describe HrrRbSsh::Authentication::Method::KeyboardInteractive::Context do
  let(:context_transport){ double('transport') }
  let(:context_username){ "username" }
  let(:context_submethods){ "submethods" }
  let(:context_variables){ {} }
  let(:context_authentication_methods){ [] }
  let(:context){ described_class.new context_transport, context_username, context_submethods, context_variables, context_authentication_methods }

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

  describe "#info_response" do
    context "before calling #info_request" do
      it "returns nil" do
        expect( context.info_response ).to be nil
      end
    end
  end
end
