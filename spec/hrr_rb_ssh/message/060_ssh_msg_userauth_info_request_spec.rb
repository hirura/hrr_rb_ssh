# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_USERAUTH_INFO_REQUEST do
  let(:id){ 'SSH_MSG_USERAUTH_INFO_REQUEST' }
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

  context "when 'num-prompts' is 0" do
    let(:message){
      {
        :'message number' => value,
        :'name'           => 'dummy',
        :'instruction'    => 'dummy',
        :'language tag'   => '',
        :'num-prompts'    => 0,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'name']),
        HrrRbSsh::DataType::String.encode(message[:'instruction']),
        HrrRbSsh::DataType::String.encode(message[:'language tag']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-prompts']),
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

  context "when 'num-prompts' is 1" do
    let(:message){
      {
        :'message number' => value,
        :'name'           => 'dummy',
        :'instruction'    => 'dummy',
        :'language tag'   => '',
        :'num-prompts'    => 1,
        :'prompt[1]'      => 'prompt[1]',
        :'echo[1]'        => false,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'name']),
        HrrRbSsh::DataType::String.encode(message[:'instruction']),
        HrrRbSsh::DataType::String.encode(message[:'language tag']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-prompts']),
        HrrRbSsh::DataType::String.encode(message[:'prompt[1]']),
        HrrRbSsh::DataType::Boolean.encode(message[:'echo[1]']),
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

  context "when 'num-prompts' is 2" do
    let(:message){
      {
        :'message number' => value,
        :'name'           => 'dummy',
        :'instruction'    => 'dummy',
        :'language tag'   => '',
        :'num-prompts'    => 2,
        :'prompt[1]'      => 'prompt[1]',
        :'echo[1]'        => false,
        :'prompt[2]'      => 'prompt[2]',
        :'echo[2]'        => false,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'name']),
        HrrRbSsh::DataType::String.encode(message[:'instruction']),
        HrrRbSsh::DataType::String.encode(message[:'language tag']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-prompts']),
        HrrRbSsh::DataType::String.encode(message[:'prompt[1]']),
        HrrRbSsh::DataType::Boolean.encode(message[:'echo[1]']),
        HrrRbSsh::DataType::String.encode(message[:'prompt[2]']),
        HrrRbSsh::DataType::Boolean.encode(message[:'echo[2]']),
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

  context "when 'num-prompts' is 3" do
    let(:message){
      {
        :'message number' => value,
        :'name'           => 'dummy',
        :'instruction'    => 'dummy',
        :'language tag'   => '',
        :'num-prompts'    => 3,
        :'prompt[1]'      => 'prompt[1]',
        :'echo[1]'        => false,
        :'prompt[2]'      => 'prompt[2]',
        :'echo[2]'        => false,
        :'prompt[3]'      => 'prompt[3]',
        :'echo[3]'        => false,
      }
    }
    let(:payload){
      [
        HrrRbSsh::DataType::Byte.encode(message[:'message number']),
        HrrRbSsh::DataType::String.encode(message[:'name']),
        HrrRbSsh::DataType::String.encode(message[:'instruction']),
        HrrRbSsh::DataType::String.encode(message[:'language tag']),
        HrrRbSsh::DataType::Uint32.encode(message[:'num-prompts']),
        HrrRbSsh::DataType::String.encode(message[:'prompt[1]']),
        HrrRbSsh::DataType::Boolean.encode(message[:'echo[1]']),
        HrrRbSsh::DataType::String.encode(message[:'prompt[2]']),
        HrrRbSsh::DataType::Boolean.encode(message[:'echo[2]']),
        HrrRbSsh::DataType::String.encode(message[:'prompt[3]']),
        HrrRbSsh::DataType::Boolean.encode(message[:'echo[3]']),
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
end
