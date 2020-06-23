# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_FAILURE do
  let(:id){ 'SSH_MSG_CHANNEL_OPEN_FAILURE' }
  let(:value){ 92 }

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
    describe "::SSH_OPEN_ADMINISTRATIVELY_PROHIBITED" do
      let(:id){ 'SSH_OPEN_ADMINISTRATIVELY_PROHIBITED' }
      let(:value){ 1 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_FAILURE::ReasonCode::SSH_OPEN_ADMINISTRATIVELY_PROHIBITED).to eq value
      end
    end

    describe "::SSH_OPEN_CONNECT_FAILED" do
      let(:id){ 'SSH_OPEN_CONNECT_FAILED' }
      let(:value){ 2 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_FAILURE::ReasonCode::SSH_OPEN_CONNECT_FAILED).to eq value
      end
    end

    describe "::SSH_OPEN_UNKNOWN_CHANNEL_TYPE" do
      let(:id){ 'SSH_OPEN_UNKNOWN_CHANNEL_TYPE' }
      let(:value){ 3 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_FAILURE::ReasonCode::SSH_OPEN_UNKNOWN_CHANNEL_TYPE).to eq value
      end
    end

    describe "::SSH_OPEN_RESOURCE_SHORTAGE" do
      let(:id){ 'SSH_OPEN_RESOURCE_SHORTAGE' }
      let(:value){ 4 }

      it "is defined" do
        expect(HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_FAILURE::ReasonCode::SSH_OPEN_RESOURCE_SHORTAGE).to eq value
      end
    end
  end

  let(:message){
    {
      :'message number'    => value,
      :'recipient channel' => 1,
      :'reason code'       => 2,
      :'description'       => 'description',
      :'language tag'      => 'language tag',
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
      HrrRbSsh::DataTypes::Uint32.encode(message[:'recipient channel']),
      HrrRbSsh::DataTypes::Uint32.encode(message[:'reason code']),
      HrrRbSsh::DataTypes::String.encode(message[:'description']),
      HrrRbSsh::DataTypes::String.encode(message[:'language tag']),
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
