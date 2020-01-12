# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_KEX_DH_GEX_REQUEST do
  let(:id){ 'SSH_MSG_KEX_DH_GEX_REQUEST' }
  let(:value){ 34 }

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
      :'message number' => value,
      :'min'            => 1024,
      :'n'              => 1024,
      :'max'            => 8192,
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataType::Byte.encode(message[:'message number']),
      HrrRbSsh::DataType::Uint32.encode(message[:'min']),
      HrrRbSsh::DataType::Uint32.encode(message[:'n']),
      HrrRbSsh::DataType::Uint32.encode(message[:'max']),
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
