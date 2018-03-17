# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_CHANNEL_EXTENDED_DATA do
  let(:id){ 'SSH_MSG_CHANNEL_EXTENDED_DATA' }
  let(:value){ 95 }

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
      id                  => value,
      'recipient channel' => 1,
      'data type code'    => 2,
      'data'              => 'data',
    }
  }
  let(:payload){
    [
      HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
      HrrRbSsh::Transport::DataType::Uint32.encode(message['recipient channel']),
      HrrRbSsh::Transport::DataType::Uint32.encode(message['data type code']),
      HrrRbSsh::Transport::DataType::String.encode(message['data']),
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
