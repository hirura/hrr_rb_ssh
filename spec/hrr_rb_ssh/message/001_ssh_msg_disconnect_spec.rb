# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_DISCONNECT do
  let(:id){ 'SSH_MSG_DISCONNECT' }
  let(:value){ 1 }

  describe "::ID" do
    it "is defined" do
      expect(described_class::ID).to eq id
    end
  end

  describe "::VALUE" do
    it "is defined" do
      expect(described_class::VALUE).to eq value
    end
  end

  describe "::ReasonCode" do
    describe "::SSH_DISCONNECT_HOST_NOT_ALLOWED_TO_CONNECT" do
      let(:id){ 'SSH_DISCONNECT_HOST_NOT_ALLOWED_TO_CONNECT' }
      let(:value){ 1 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_HOST_NOT_ALLOWED_TO_CONNECT).to eq value
      end
    end

    describe "::SSH_DISCONNECT_PROTOCOL_ERROR" do
      let(:id){ 'SSH_DISCONNECT_PROTOCOL_ERROR' }
      let(:value){ 2 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_PROTOCOL_ERROR).to eq value
      end
    end

    describe "::SSH_DISCONNECT_KEY_EXCHANGE_FAILED" do
      let(:id){ 'SSH_DISCONNECT_KEY_EXCHANGE_FAILED' }
      let(:value){ 3 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_KEY_EXCHANGE_FAILED).to eq value
      end
    end

    describe "::SSH_DISCONNECT_RESERVED" do
      let(:id){ 'SSH_DISCONNECT_RESERVED' }
      let(:value){ 4 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_RESERVED).to eq value
      end
    end

    describe "::SSH_DISCONNECT_MAC_ERROR" do
      let(:id){ 'SSH_DISCONNECT_MAC_ERROR' }
      let(:value){ 5 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_MAC_ERROR).to eq value
      end
    end

    describe "::SSH_DISCONNECT_COMPRESSION_ERROR" do
      let(:id){ 'SSH_DISCONNECT_COMPRESSION_ERROR' }
      let(:value){ 6 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_COMPRESSION_ERROR).to eq value
      end
    end

    describe "::SSH_DISCONNECT_SERVICE_NOT_AVAILABLE" do
      let(:id){ 'SSH_DISCONNECT_SERVICE_NOT_AVAILABLE' }
      let(:value){ 7 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_SERVICE_NOT_AVAILABLE).to eq value
      end
    end

    describe "::SSH_DISCONNECT_PROTOCOL_VERSION_NOT_SUPPORTED" do
      let(:id){ 'SSH_DISCONNECT_PROTOCOL_VERSION_NOT_SUPPORTED' }
      let(:value){ 8 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_PROTOCOL_VERSION_NOT_SUPPORTED).to eq value
      end
    end

    describe "::SSH_DISCONNECT_HOST_KEY_NOT_VERIFIABLE" do
      let(:id){ 'SSH_DISCONNECT_HOST_KEY_NOT_VERIFIABLE' }
      let(:value){ 9 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_HOST_KEY_NOT_VERIFIABLE).to eq value
      end
    end

    describe "::SSH_DISCONNECT_CONNECTION_LOST" do
      let(:id){ 'SSH_DISCONNECT_CONNECTION_LOST' }
      let(:value){ 10 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_CONNECTION_LOST).to eq value
      end
    end

    describe "::SSH_DISCONNECT_BY_APPLICATION" do
      let(:id){ 'SSH_DISCONNECT_BY_APPLICATION' }
      let(:value){ 11 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION).to eq value
      end
    end

    describe "::SSH_DISCONNECT_TOO_MANY_CONNECTIONS" do
      let(:id){ 'SSH_DISCONNECT_TOO_MANY_CONNECTIONS' }
      let(:value){ 12 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_TOO_MANY_CONNECTIONS).to eq value
      end
    end

    describe "::SSH_DISCONNECT_AUTH_CANCELLED_BY_USER" do
      let(:id){ 'SSH_DISCONNECT_AUTH_CANCELLED_BY_USER' }
      let(:value){ 13 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_AUTH_CANCELLED_BY_USER).to eq value
      end
    end

    describe "::SSH_DISCONNECT_NO_MORE_AUTH_METHODS_AVAILABLE" do
      let(:id){ 'SSH_DISCONNECT_NO_MORE_AUTH_METHODS_AVAILABLE' }
      let(:value){ 14 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_NO_MORE_AUTH_METHODS_AVAILABLE).to eq value
      end
    end

    describe "::SSH_DISCONNECT_ILLEGAL_USER_NAME" do
      let(:id){ 'SSH_DISCONNECT_ILLEGAL_USER_NAME' }
      let(:value){ 15 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_ILLEGAL_USER_NAME).to eq value
      end
    end
  end

  let(:message){
    {
      :'message number' => value,
      :'reason code'    => 1,
      :'description'    => 'description',
      :'language tag'   => 'language tag',
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataType::Byte.encode(message[:'message number']),
      HrrRbSsh::DataType::Uint32.encode(message[:'reason code']),
      HrrRbSsh::DataType::String.encode(message[:'description']),
      HrrRbSsh::DataType::String.encode(message[:'language tag']),
    ].join
  }

  describe "#encode" do
    it "returns payload encoded" do
      expect(described_class.new.encode(message)).to eq payload
    end
  end

  describe "#decode" do
    it "returns message decoded" do
      expect(described_class.new.decode(payload)).to eq message
    end
  end
end
