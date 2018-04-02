# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE do
  let(:id){ 'SSH_MSG_USERAUTH_FAILURE' }
  let(:value){ 51 }

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
      'message number'                    => value,
      'authentications that can continue' => ['publickey', 'password'],
      'partial success'                   => false,
    }
  }
  let(:payload){
    [
      HrrRbSsh::Transport::DataType::Byte.encode(message['message number']),
      HrrRbSsh::Transport::DataType::NameList.encode(message['authentications that can continue']),
      HrrRbSsh::Transport::DataType::Boolean.encode(message['partial success']),
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
