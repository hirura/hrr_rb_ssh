# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Messages::SSH_MSG_CHANNEL_SUCCESS do
  let(:id){ 'SSH_MSG_CHANNEL_SUCCESS' }
  let(:value){ 99 }

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

  let(:message){
    {
      :'message number'    => value,
      :'recipient channel' => 1,
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataTypes::Byte.encode(message[:'message number']),
      HrrRbSsh::DataTypes::Uint32.encode(message[:'recipient channel']),
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
