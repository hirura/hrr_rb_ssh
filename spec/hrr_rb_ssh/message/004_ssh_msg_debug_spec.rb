# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_DEBUG do
  let(:id){ 'SSH_MSG_DEBUG' }
  let(:value){ 4 }

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
      id               => value,
      'always_display' => true,
      'message'        => 'debug message',
      'language tag'   => '',
    }
  }
  let(:payload){
    [
      HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
      HrrRbSsh::Transport::DataType::Boolean.encode(message['always_display']),
      HrrRbSsh::Transport::DataType::String.encode(message['message']),
      HrrRbSsh::Transport::DataType::String.encode(message['language tag']),
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
