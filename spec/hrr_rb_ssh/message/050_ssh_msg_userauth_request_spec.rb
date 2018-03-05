# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST do
  let(:id){ 'SSH_MSG_USERAUTH_REQUEST' }
  let(:value){ 50 }

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

  context "when 'method name' is \"none\"" do
    let(:message){
      {
        id             => value,
        'user name'    => 'rspec',
        'service name' => 'ssh-connection',
        'method name'  => 'none',
      }
    }
    let(:payload){
      [
        HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
        HrrRbSsh::Transport::DataType::String.encode(message['user name']),
        HrrRbSsh::Transport::DataType::String.encode(message['service name']),
        HrrRbSsh::Transport::DataType::String.encode(message['method name']),
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

  context "when 'method name' is \"password\"" do
    let(:message){
      {
        id                   => value,
        'user name'          => 'rspec',
        'service name'       => 'ssh-connection',
        'method name'        => 'password',
        'FALSE'              => false,
        'plaintext password' => 'password',
      }
    }
    let(:payload){
      [
        HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
        HrrRbSsh::Transport::DataType::String.encode(message['user name']),
        HrrRbSsh::Transport::DataType::String.encode(message['service name']),
        HrrRbSsh::Transport::DataType::String.encode(message['method name']),
        HrrRbSsh::Transport::DataType::Boolean.encode(message['FALSE']),
        HrrRbSsh::Transport::DataType::String.encode(message['plaintext password']),
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

  context "when 'method name' is \"publickey\"" do
    let(:message){
      {
        id                           => value,
        'user name'                  => 'rspec',
        'service name'               => 'ssh-connection',
        'method name'                => 'publickey',
        'TRUE'                       => true,
        'public key algorithm name'  => 'ssh-rsa',
        'public key blob'            => 'dummy',
        'signature'                  => 'dummy',
      }
    }
    let(:payload){
      [
        HrrRbSsh::Transport::DataType::Byte.encode(message[id]),
        HrrRbSsh::Transport::DataType::String.encode(message['user name']),
        HrrRbSsh::Transport::DataType::String.encode(message['service name']),
        HrrRbSsh::Transport::DataType::String.encode(message['method name']),
        HrrRbSsh::Transport::DataType::Boolean.encode(message['TRUE']),
        HrrRbSsh::Transport::DataType::String.encode(message['public key algorithm name']),
        HrrRbSsh::Transport::DataType::String.encode(message['public key blob']),
        HrrRbSsh::Transport::DataType::String.encode(message['signature']),
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
end
