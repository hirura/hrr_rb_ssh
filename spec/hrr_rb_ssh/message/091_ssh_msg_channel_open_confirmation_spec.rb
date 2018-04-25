# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION do
  let(:id){ 'SSH_MSG_CHANNEL_OPEN_CONFIRMATION' }
  let(:value){ 91 }

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

  context "when 'channel type' is \"session\"" do
    let(:message){
      {
        :'message number'      => value,
        :'recipient channel'   => 1,
        :'sender channel'      => 2,
        :'initial window size' => 3,
        :'maximum packet size' => 4,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'sender channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'initial window size']),
        HrrRbSsh::DataType::Uint32.encode(message[:'maximum packet size']),
      ].join
    }

    let(:complementary_message){
      {
        'channel type' => 'session',
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

  context "when 'channel type' is \"x11\"" do
    let(:message){
      {
        :'message number'      => value,
        :'recipient channel'   => 1,
        :'sender channel'      => 2,
        :'initial window size' => 3,
        :'maximum packet size' => 4,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'sender channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'initial window size']),
        HrrRbSsh::DataType::Uint32.encode(message[:'maximum packet size']),
      ].join
    }

    let(:complementary_message){
      {
        'channel type' => 'x11',
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

  context "when 'channel type' is \"forwarded-tcpip\"" do
    let(:message){
      {
        :'message number'             => value,
        :'recipient channel'          => 1,
        :'sender channel'             => 2,
        :'initial window size'        => 3,
        :'maximum packet size'        => 4,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'sender channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'initial window size']),
        HrrRbSsh::DataType::Uint32.encode(message[:'maximum packet size']),
      ].join
    }

    let(:complementary_message){
      {
        'channel type' => 'forwarded-tcpip',
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

  context "when 'channel type' is \"direct-tcpip\"" do
    let(:message){
      {
        :'message number'        => value,
        :'recipient channel'     => 1,
        :'sender channel'        => 2,
        :'initial window size'   => 3,
        :'maximum packet size'   => 4,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::Uint32.encode(message[:'recipient channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'sender channel']),
        HrrRbSsh::DataType::Uint32.encode(message[:'initial window size']),
        HrrRbSsh::DataType::Uint32.encode(message[:'maximum packet size']),
      ].join
    }

    let(:complementary_message){
      {
        'channel type' => 'direct-tcpip',
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
end
