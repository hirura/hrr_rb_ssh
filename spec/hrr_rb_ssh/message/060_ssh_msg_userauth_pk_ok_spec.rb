# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_USERAUTH_PK_OK do
  let(:id){ 'SSH_MSG_USERAUTH_PK_OK' }
  let(:value){ 60 }

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
      :'message number'                             => value,
      :'public key algorithm name from the request' => 'dummy',
      :'public key blob from the request'           => 'dummy',
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataType::Byte.encode(message[:'message number']),
      HrrRbSsh::DataType::String.encode(message[:'public key algorithm name from the request']),
      HrrRbSsh::DataType::String.encode(message[:'public key blob from the request']),
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
