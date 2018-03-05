# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_KEXDH_INIT do
  let(:id){ 'SSH_MSG_KEXDH_INIT' }
  let(:value){ 30 }

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
      id  => value,
      'e' => 1234567890,
    }
  }
  let(:payload){
    [
      HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
      HrrRbSsh::Transport::DataType::Mpint.encode(message['e']),
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
