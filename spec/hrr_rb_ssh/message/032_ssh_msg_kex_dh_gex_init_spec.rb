# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_KEX_DH_GEX_INIT do
  let(:id){ 'SSH_MSG_KEX_DH_GEX_INIT' }
  let(:value){ 32 }

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
      'message number' => value,
      'e'              => 1234567890,
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataType::Byte.encode(message['message number']),
      HrrRbSsh::DataType::Mpint.encode(message['e']),
    ].join
  }

  describe ".encode" do
    it "returns payload encoded" do
      expect(described_class.encode(message)).to eq payload
    end
  end

  describe ".decode" do
    it "returns message decoded" do
      expect(described_class.decode(payload)).to eq message
    end
  end
end
