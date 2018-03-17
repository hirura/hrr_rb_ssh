# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS do
  let(:id){ 'SSH_MSG_REQUEST_SUCCESS' }
  let(:value){ 81 }

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
      id                                  => value,
      'port that was bound on the server' => 1080,
    }
  }
  let(:payload){
    [
      HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
      HrrRbSsh::Transport::DataType::Uint32.encode(message['port that was bound on the server']),
    ].join
  }

  let(:complementary_message){
    {
      'request name' => 'tcpip-forward',
    }
  }

  describe ".encode" do
    it "returns payload encoded" do
      expect(described_class.encode(message, complementary_message)).to eq payload
    end
  end

  describe ".decode" do
    it "returns message decoded" do
      expect(described_class.decode(payload, complementary_message)).to eq message
    end
  end
end
