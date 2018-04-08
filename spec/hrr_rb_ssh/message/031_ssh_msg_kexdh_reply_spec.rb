# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_KEXDH_REPLY do
  let(:id){ 'SSH_MSG_KEXDH_REPLY' }
  let(:value){ 31 }

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
      'message number'                                => value,
      'server public host key and certificates (K_S)' => 'dummy',
      'f'                                             => 1234567890,
      'signature of H'                                => 'dummy',
    }
  }
  let(:payload){
    [
      HrrRbSsh::DataType::Byte.encode(message['message number']),
      HrrRbSsh::DataType::String.encode(message['server public host key and certificates (K_S)']),
      HrrRbSsh::DataType::Mpint.encode(message['f']),
      HrrRbSsh::DataType::String.encode(message['signature of H']),
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
