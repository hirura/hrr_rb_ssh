# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Authentication::Method::Publickey::Context do
  let(:username){ 'username' }
  let(:algorithm){ double('algorithm') }
  let(:session_id){ 'session id' }
  let(:public_key_algorithm_name){ "supported" }
  let(:public_key_blob){ "dummy" }
  let(:message){
    {
      'message number'            => HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
      'user name'                 => username,
      'service name'              => 'ssh-connection',
      'method name'               => 'publickey',
      'with signature'            => true,
      'public key algorithm name' => public_key_algorithm_name,
      'public key blob'           => public_key_blob,
      'signature'                 => 'signature',
    }
  }
  let(:context){ described_class.new username, algorithm, session_id, message }

  describe ".new" do
    it "takes four arguments: username, algorithm, session_id, message" do
      expect { context }.not_to raise_error
    end
  end

  describe "#username" do
    it "returns \"username\"" do
      expect( context.username ).to be username
    end
  end

  describe "#session_id" do
    it "returns \"session id\"" do
      expect( context.session_id ).to be session_id
    end
  end

  describe "#message_number" do
    it "returns \"#{HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE}\"" do
      expect( context.message_number ).to be HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE
    end
  end

  describe "#service_name" do
    it "returns \"ssh-connection\"" do
      expect( context.service_name ).to eq "ssh-connection"
    end
  end

  describe "#method_name" do
    it "returns \"publickey\"" do
      expect( context.method_name ).to eq "publickey"
    end
  end

  describe "#with_signature" do
    it "returns true" do
      expect( context.with_signature ).to be true
    end
  end

  describe "#public_key_algorithm_name" do
    it "returns \"supported\"" do
      expect( context.public_key_algorithm_name ).to be public_key_algorithm_name
    end
  end

  describe "#public_key_blob" do
    it "returns \"dummy\"" do
      expect( context.public_key_blob ).to be public_key_blob
    end
  end

  describe "#signature" do
    it "returns \"signature\"" do
      expect( context.signature ).to eq "signature"
    end
  end

  describe "#verify" do
    context "when verify_username returns false" do
      let(:arg_username){ "mismatch" }
      let(:arg_public_key){ "PUBLIC KEY" }

      it "returns false" do
        expect( context.verify arg_username, public_key_algorithm_name, arg_public_key ).to be false
      end
    end

    context "when verify_public_key_algorithm_name returns false" do
      let(:arg_public_key_algorithm_name){ "mismatch" }
      let(:arg_public_key){ "PUBLIC KEY" }

      it "returns false" do
        expect( context.verify username, arg_public_key_algorithm_name, arg_public_key ).to be false
      end
    end

    context "when verify_public_key returns false" do
      let(:arg_public_key){ "PUBLIC KEY" }

      it "returns false" do
        expect( algorithm ).to receive(:verify_public_key).with(public_key_algorithm_name, arg_public_key, public_key_blob).and_return(false).once
        expect( context.verify username, public_key_algorithm_name, arg_public_key ).to be false
      end
    end

    context "when verify_signature returns false" do
      let(:arg_public_key){ "PUBLIC KEY" }

      it "returns false" do
        expect( algorithm ).to receive(:verify_public_key).with(public_key_algorithm_name, arg_public_key, public_key_blob).and_return(true).once
        expect( algorithm ).to receive(:verify_signature).with(session_id, message).and_return(false).once
        expect( context.verify username, public_key_algorithm_name, arg_public_key ).to be false
      end
    end

    context "when all verify_xxx returns true" do
      let(:arg_public_key){ "PUBLIC KEY" }

      it "returns true" do
        expect( algorithm ).to receive(:verify_public_key).with(public_key_algorithm_name, arg_public_key, public_key_blob).and_return(true).once
        expect( algorithm ).to receive(:verify_signature).with(session_id, message).and_return(true).once
        expect( context.verify username, public_key_algorithm_name, arg_public_key ).to be true
      end
    end
  end
end
